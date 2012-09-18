class thumbslug::install {
  include candlepin::install

	package {"katello-thumbslug":
    require => Yumrepo["candlepin::install:katello-candlepin"],
    ensure  => installed
  }
}
