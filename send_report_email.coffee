models          = require '../../models'
fs              = require 'fs'
Mailer          = require './smtp'
_               = require 'underscore'



email_pattern_regex = /^([\w-.!#$%&'*+-=?^_`{|}~]+)@((?:\w+\.)+)(?:[a-zA-Z]{2,4})$/



send_email = (bcc, subject, attachment_name, attachment) ->
  mail_config = JSON.parse fs.readFileSync('./smtp_config.json','utf8')
  mailer = new Mailer(mail_config)
  mailer.send {bcc: bcc, subject: subject, attachments: [{fileName: attachment_name, filePath: "./#{attachment}"}]}

  
  
# notes中某项中有员工编号字样的认为它后面的是code值如:本单位xxx员工编号为:xxxxxxx
pattern =
  '员工编号' : 'code'
  '姓名'     : 'name'
  '性别'     : 'sex'
  '年龄'     : 'age'
  '身份证'   : 'id'
  '电话'     : 'tel'
  '公司'     : 'source'
  '部门'     : 'division'
  '条码'     : 'barcode'
  '体检日期' : 'check_date'

rename_report = (profile, file_name) ->
  #  profile.defineGetter 'code', ->
  # _(@notes).find((note) -> /.*编号[\:\：]?/.test(note)).replace(/.*编号[\:\：]?/, '')
  for key,value of pattern
    file_name = file_name.replace key, profile[value] or ''
  # TODO: 没有得到条码
  file_name


  
  # models 'hswk.healskare.com', (err, models) ->
  # return err if err
  # console.log models
  # Record = models.Record
  # Batch = models.Batch
mongoose = require 'mongoose'
batch = require '../../models/Batch/'
record = require '../../models/Record/'
console.log batch
mongoose.connect('mongodb://localhost/test')
Record = mongoose.model('Record',record)
Batch = mongoose.model('Batch',batch)
# barcode = '10000746'
module.exports = (barcode, callback) ->
  Record.findOne(barcode: barcode).exec (err, record) ->
    return callback err if err
    if record.profile.batch
      Batch.findById(record.profile.batch).exec (err, batch) ->
        return callback err if err
        new_report_name = rename_report record.profile, batch.rename_pattern or '姓名'
        send_email batch.send_email, 'test_subject', new_report_name, 'send_report_email.coffee'
    address = []
    for note in record.profile.notes when email_pattern_regex.test note
      address.push note
    send_email address, 'test_subject', '姓名', 'send_report_email.coffee'
