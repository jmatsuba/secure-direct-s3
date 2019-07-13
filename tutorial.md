# Tutorial

Written by James Matsuba

**TLDR:** This a guide on how the example app was put together and would be helpful if you wanted to use this in a existing app.

## Background
Recently tasked with having to create a uploader multiple for private files, I found myself annoyed with the lack of good implementation examples. My first instict was to see what the popular upload solutions for Ruby and Rails offered.  I was able to get secure uploads working using [carrierwave](https://github.com/carrierwaveuploader/carrierwave). However, the implementation was using the pass through method, meaning, it was using the rails server as a temporary cache. Files would be uploaded to rails server then uploaded to s3. This was going to be a problem as I wanted my users to be able to upload multiple larger pdfs and images. Carrierwave has a gem called [carrierwave_direct](https://github.com/dwilkie/carrierwave_direct) to help manage direct uploads, however, it only supports single file uploads. Meaning if you had 5 seperate files you wanted uploaded you would need to have 5 steps for those uploads. Not ideal from UX perspective.  

My search for a solution lead me to the [jQuery File Upload Plugin](https://github.com/blueimp/jQuery-File-Upload) which looks like a fairly active plugin. However, there was some frustration as all of the example rails examples and documentation was painfully out of date. Many of them were 7+ years old and no longer functioning and from the rails 3.x era. After some searching I found heroku guide but it was tailored for images and public files and did not provide any completed examples that could be easily tested, and was for pubic image files. This guide is based off of the heroku guide but has been updated and tailored for private file uploads.


## Strategy

Get the uploader working with the least number of dependencies, in a fresh rails app, and in a easy to understand format. This was it can be re-implemented in any rails app.

## Prequisite - S3 Bucket

In order to set up this guide you'll need to setup a S3 bucket. Heroku has a [good guide](https://devcenter.heroku.com/articles/s3){: target="_blank"} on how to do this.

## Step 1 - CORS 

In your S3 Bucket you will need to add a CORS configuration. You can find this in the permissions tab of your S3 bucket. Learn more about CORS [here](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing){: target="_blank"}.

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
    <AllowedOrigin>http://localhost:3000</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
  </CORSRule>
</CORSConfiguration>
```

## Step 2 - Setup a new Rails App  
```
rails new secure-direct-s3 --skip-coffee
```

I personally don't use coffeescript so I typically will add a `--skip-coffee` to my generator code. This skips adding coffeescript to the Gemfile and defaults the future generators to use javascript. For the purpose of thus guide I used the latest stablee version of rails (5.2.3) and ruby (2.6.3).  

## Step 3 - Run Generator to Build a Basic Model


```
rails generate scaffold user name file1_key file2_key file3_key 
```

This will give us a quick and dirty way to get this up and running fast. If adding to a new project you just need to add a migration to add a string field  to an existing model which will store the s3 file path (or key in S3 terminology).

```
rails db:migrate
```

Don't forget to migrate those generated migration or your custom migration.


## Step 4 - Install Dependencies

`Gemfile`
```
// Near the top of your Gemfile
gem 'dotenv-rails', groups: [:development, :test]

// In a appropriate place in your Gemfile, for a new 
// project I would put it just before the :development group
gem 'jquery-rails'
gem 'aws-sdk', '~> 3'
```

Terminal
```
bundle
```

`dotenv-rails` - Is to allow you to use a .env locally, so you do not need to commit your confidential keys.  
`jquery-rails` - I needed as a dependency to the jQuery-File-Upload plugin.  
`aws-sdk` - Is the official sdk for aws. We are using version 3 of the API so add a '~> 3'. 

```bash
curl -o app/assets/javascripts/z.jquery.fileupload.js https://raw.githubusercontent.com/blueimp/jQuery-File-Upload/master/js/jquery.fileupload.js
curl -o app/assets/javascripts/jquery.ui.widget.js https://raw.githubusercontent.com/blueimp/jQuery-File-Upload/master/js/vendor/jquery.ui.widget.js
```

These curl commands will download the latest jQuery file upload plugin and the matching jquery ui dependency. 

We are ensuring the `jquery.fileupload.js` to be loaded after any other jQuery files by prepending a z to its filename.

If you are loading all JavaScript files in your `application.js` with a `//= require_tree .` directive than this JavaScript will be automatically available otherwise you will need to explicitly require it:

```
//= require jquery.ui.widget
//= require z.jquery.fileupload
```


## Step 5 - Setup Initializer for AWS

`/config/initializers/aws.rb`
```ruby
Aws.config.update({
  region: ENV['AWS_REGION'] || 'us-east-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
})

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
```


.env
```
S3_BUCKET=bucket-name
AWS_REGION=aws-region
AWS_ACCESS_KEY_ID=aws-access-key
AWS_SECRET_ACCESS_KEY=aws-secret-key
```

## Step 6 - Setup the Presigned Post

We want the `@s3_direct_post` variable to be available when creating and editing the user, so let’s set this up in a `before_action` method:

`app/controllers/users_controller.rb`
```ruby
class UsersController < ApplicationController
...
  before_action :set_s3_direct_post, only: [:new, :edit ]
...

private
  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'private')
  end

```

Two critical things you need to know here. You can set the location of where your files will be uploaded and it is where you set your acl to private.

For the purpose of this example we are using `uuid`s to generate unique paths per upload session. However, you may find grouping the upload by user or by file type may be helpful. You can set the acl to `public_read` here if you wanted to upload files that are public.


## Step 7 - Client Side Code for Uploading

This is a big step. We need to modify the views generated by rails to use the jQuery file upload plugin and the pre-signed post to upload your files directly to s3, and to add the file key to the form.


In your users `_form.html.erb` modify your form_for to include the following.

`app/views/users/_form.html.erb` 
```ruby
<%= form_for(@user, html: { class: 'directUpload', data: { 'form-data' => (@s3_direct_post.fields), 'url' => @s3_direct_post.url, 'host' => URI.parse(@s3_direct_post.url).host } }) do |f| %>
```

You will also need to change the `text_feild`s to `file_field`.


```html
<div class="field">
  <%= f.label :file1_key %><br>
  <%= f.file_field :file1_key %>
</div>

<div class="field">
  <%= f.label :file2_key %><br>
  <%= f.file_field :file2_key %>
</div>

<div class="field">
  <%= f.label :file3_key %><br>
  <%= f.file_field :file3_key %>
</div>
```

Lets add some basic styling

`app/assets/stylesheets/users.scss`
```css
.progress {
  max-width: 600px;
  margin:    0.2em 0 0.2em 0;
}

.progress .bar {
  height:  1.2em;
  padding-left: 0.2em;
  color:   white;
  display: none;
}
```

Here is the custom code that will look for a forms with the class of `directUpload` then will use the pre-signed post and the jQuery file upload plugin to directly upload files to s3 when files are selected in the form.

`app/assets/javascripts/users.js`
```javascript
$(function() {
  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput    = $(elem);
    var form         = $(fileInput.parents('form:first'));
    var submitButton = form.find('input[type="submit"]');
    var progressBar  = $("<div class='bar'></div>");
    var barContainer = $("<div class='progress'></div>").append(progressBar);
    fileInput.after(barContainer);
    fileInput.fileupload({
      fileInput:       fileInput,
      url:             form.data('url'),
      type:            'POST',
      autoUpload:       true,
      formData:         form.data('form-data'),
      paramName:        'file', // S3 does not like nested name fields i.e. name="user[file1_key]"
      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
      replaceFileInput: false,
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        progressBar.css('width', progress + '%')
      },
      start: function (e) {
        submitButton.prop('disabled', true);

        progressBar.
          css('background', 'green').
          css('display', 'block').
          css('width', '0%').
          text("Loading...");
      },
      done: function(e, data) {
        submitButton.prop('disabled', false);
        progressBar.text("Uploading done");

        // extract key and generate URL from response
        var key   = $(data.jqXHR.responseXML).find("Key").text();
        var url   = '//' + form.data('host') + '/' + key;

        // create hidden field
        var input = $("<input />", { type:'hidden', name: fileInput.attr('name'), value: url })
        form.append(input);
      },
      fail: function(e, data) {
        submitButton.prop('disabled', false);

        progressBar.
          css("background", "red").
          text("Failed");
      }
    });
  });
});
```

## Step 8 - User Model Code for Downloading

`app/models/user.rb`
```ruby
class User < ApplicationRecord
  ["file1", "file2", 'file3'].each do |file|
    define_method "#{file}_secure_url" do
      secure_aws_url(read_attribute("#{file}_key"))
    end

    define_method "#{file}_filename" do
      parse_filename(read_attribute("#{file}_key"))
    end
  end

  private

  def secure_aws_url(key)
    key.present? ? S3_BUCKET.object(key).presigned_url(:get) : nil
  end

  def parse_filename(key)
    key.present? ? key.split('/').last : nil
  end
end
```

It should be noted you may opt for a simplier implementation of this as meta programing methods adds a layer of complexity and makes your code harder to read. However, if you have many file feilds fields on a model this will DRY up your code.  

In my opinion the S3 code in `secure_aws_url` should also be moved into a service object.

## Step 9 - Client Side Code Downloading

The last step need to get this example working is to modify the links in the app to use the secure urls. Modify the links in both the show and index erb files to use the created methods in the previous step.

`app/views/users/index.html.erb`
`app/views/users/show.html.erb`
```html
  <td><%= user.file1_key? ? link_to(user.file1_filename, user.file1_secure_url) : nil %></td>
  <td><%= user.file2_key? ? link_to(user.file2_filename, user.file2_secure_url) : nil %></td>
  <td><%= user.file3_key? ? link_to(user.file3_filename, user.file3_secure_url) : nil %></td>
```

## Summary
This is a basic example of how to do private uploads with rails, using a direct to S3 implementation. Your could further enhance security by adding time to access restrictions on the presigned urls that would cuase the urls to expire. 
