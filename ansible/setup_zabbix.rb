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

#user_id_for = zbx.users.all
#user_id = zbx.users.get_id(name: 'Zabbix')
#p zbx.users.all

group_id_for = zbx.hostgroups.all
linux_servers = group_id_for['Linux servers']
zabbis_servers = group_id_for['Zabbix servers']

template_id_for = zbx.templates.all
linux_template = template_id_for['Template OS Linux']
server_template = template_id_for['Template App Zabbix Server']

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

host_id_for = zbx.hosts.all
server_host_id = host_id_for[SERVER_HOST.sub(/\.do$/, '')]

zbx.templates.mass_add(hosts_id: all_host_ids, templates_id: [linux_template])
zbx.templates.mass_add(hosts_id: [server_host_id], templates_id: [server_template])
zbx.client.api_request({
  method: 'host.massupdate',
  params: {
    hosts: all_host_ids.map { |host_id| { hostid: host_id } },
    inventory_mode: 1,
  },
})
