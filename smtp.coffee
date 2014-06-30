mailer = require 'nodemailer'
fs = require 'fs'

Mailer = (options) ->
  this.smtp = smtp = mailer.createTransport 'SMTP',options
  this

#email:{from: 'jianyanshuju@wedocare.com',to: 'arieslian@qq.com',subject: 'subject',html: 'content',text: 'content',attachments: 'attachments'}
Mailer.prototype.send = (email) ->
  #attachments
  #fileName:'string
  #contents: "string" or "Buffer" or
  #filePath:'path' or
  #streamSource: 'stream' fs.createReadStream 'file_path'
  email.from = 'jianyanshuju@wedocare.com'
  @smtp.sendMail email, (error) ->
    if error then console.log(error) else console.log('success')

module.exports = Mailer
