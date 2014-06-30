#reuqire
MailParser = require('mailparser').MailParser
AdmZip     = require 'adm-zip'
pdftotext  = require 'pdftotextjs'
fs         = require 'fs'
pdfparser  = require './pdfparser'

#获取邮件
email = {}
path = "./pdfs/"
email.get_emails = (imap,callback) ->
  pdf_names =[]
  close_box =(err,emails) ->
    imap.closeBox ->
      console.log 'this box is closed'
      callback(err,emails)
  imap.openBox 'INBOX',on,(err,boxes)->
    #callback('',pdf_names)
    return close_box(err)  if err
    imap.search ['UNSEEN',['SINCE','2013/10/10']],(err,results)->
      console.log "open:#{results}"
      return close_box(err) if err
      return close_box('',[]) unless results && results.length  
      mails_count = results.length
      results.forEach (seqno)->
        fetch = imap.fetch seqno,bodies:''
        fetch.on 'message',(message,seqno2)->
          buffer = ''
          message.on 'body',(stream)->
            stream.on 'data',(chunk)->
              buffer += chunk.toString('utf8')
            stream.on 'end',->
              console.log 'stream is end'
              mailparser =  new MailParser()
              mailparser.on 'end',(mail)->
                console.log 'mail is end'
                pdf_names.push {name: mail.from[0].name,files :mail.attachments}
                imap.addFlags seqno, '\\Seen',(err)->
                  console.log err
                  close_box('',pdf_names) if --mails_count is 0
              mailparser.write buffer
              mailparser.end()

  email.read_emails = (emails,doctors,callback) ->
    radiation = []
    emails_count = emails.length
    emails.forEach (email)->
      files_count = email.files.length
      email.files.forEach (attach)->
        zip = new AdmZip attach.content
        pdfs_count = zip.getEntries().length
        zip.getEntries().forEach (pdf)->
          fs.writeFile "#{path}#{pdf.name}",pdf.getData(),->
            ray = pdfparser.parser "#{path}#{pdf.name}",doctor[email.name]
            radiation.push ray
            files_count-- if --pdfs_count is 0
            emails_count-- if files_count is 0
            callback(radiation) if emails_count is 0


module.exports = email

