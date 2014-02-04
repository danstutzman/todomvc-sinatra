#!/usr/bin/ruby
require 'zabbixapi'

# For API docs, see:
#   https://www.zabbix.com/documentation/2.2/manual/api
#   http://rubydoc.info/gems/zabbixapi/0.6.4/frames

raise "Arg 1: hostname of zabbix server" if ARGV[0].nil?
SERVER_HOST = ARGV[0]

PASSWORD_PATH = "#{ENV['HOME']}/.zabbix_admin"
zbx = ZabbixApi.connect({
  url:      "http://#{SERVER_HOST}/zabbix/api_jsonrpc.php",
  user:     'Admin',
  password: File.read(PASSWORD_PATH).strip,
})

mediatype_id_for = zbx.mediatypes.all
zbx.mediatypes.update({
  mediatypeid: mediatype_id_for['Email'],
  smtp_server: 'localhost',
  smtp_helo: 'localhost',
  smtp_email: 'root@localhost',
  status: 0 # 0=enabled, strangely enough
})

user_id_for = zbx.users.all
zbx.client.api_request({
  method: 'user.updatemedia',
  params: {
    users: [{ userid: user_id_for['Zabbix'] }],
    medias: [{
      mediatypeid: 1, # email
      sendto:      'dtstutz@gmail.com',
      period:      '1-7,00:00-24:00',
      active:      0, # 0=active, strangely enough
      severity:    63, # all severity levels
    }],
  },
})#p zbx.users.all

exit 1

group_id_for = zbx.hostgroups.all
linux_servers = group_id_for['Linux servers']
zabbis_servers = group_id_for['Zabbix servers']

template_id_for = zbx.templates.all
linux_template = template_id_for['Template OS Linux']

ip_host_pairs = %w[
  162.243.127.91|todomvc-practice3
  107.170.30.54|todomvc-practice2
]

all_host_ids = []
ip_host_pairs.each do |ip_host_pair|
  ip, hostname = ip_host_pair.split('|')
  host_id = zbx.hosts.create_or_update({
    host: hostname,
    interfaces: [{
        type: 1,
        main: 1,
        ip: ip,
        dns: "#{hostname}.do",
        port: 10050,
        useip: 1
    }],
    groups: [ groupid: linux_servers ],
  })
  all_host_ids.push host_id
end

zbx.templates.mass_add(hosts_id: all_host_ids, templates_id: [linux_template])
zbx.client.api_request({
  method: 'host.massupdate',
  params: {
    hosts: all_host_ids.map { |host_id| { hostid: host_id } },
    inventory_mode: 1,
  },
})
