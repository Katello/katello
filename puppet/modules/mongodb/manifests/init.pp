class mongodb {
  include mongodb::install
  include mongodb::config
  include mongodb::service
}
