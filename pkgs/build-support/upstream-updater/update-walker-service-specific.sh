SF_redirect () {
  redirect
  process 'http://[a-z]+[.]dl[.]sourceforge[.]net/' 'mirror://sourceforge/'
  process '[?].*' ''
}

SF_version_dir () {
  version_link 'http://sourceforge.net/.+/([-.a-z0-9]+-)?[0-9.]+/$'
}
