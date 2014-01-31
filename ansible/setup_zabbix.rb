#!/usr/bin/ruby
require 'zabbixapi'

raise "Arg 1: hostname of zabbix server" if ARGV[0].nil?
IP = ARGV[0]

PASSWORD_PATH = "#{ENV['HOME']}/.zabbix_admin"
zbx = ZabbixApi.connect({
  url:      "http://#{IP}/zabbix/api_jsonrpc.php",
  user:     'Admin',
  password: File.read(PASSWORD_PATH).strip,
})

#user_id_for = zbx.users.all
#user_id = zbx.users.get_id(name: 'Zabbix')
#p zbx.users.all

group_id_for = zbx.hostgroups.all
linux_servers = group_id_for['Linux servers']
zabbis_servers = group_id_for['Zabbix servers']

template_id_for = zbx.templates.all
linux_template = template_id_for['Template OS Linux']

host_id = zbx.hosts.create_or_update({
  host: 'todomvc-practice2.do',
  interfaces: [{
      type: 1,
      main: 1,
      ip: '107.170.30.54',
      dns: 'todomvc-practice2.do',
      port: 10050,
      useip: 1
  }],
  groups: [ groupid: linux_servers ],
})
#host_id_for = zbx.hosts.all

zbx.templates.mass_add(hosts_id: [host_id], templates_id: [linux_template])
