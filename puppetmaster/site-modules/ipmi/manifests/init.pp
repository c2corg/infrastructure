class ipmi {

  include ipmi::client
  include ipmi::setup
  include ipmi::collectd
  include ipmi::riemann

}
