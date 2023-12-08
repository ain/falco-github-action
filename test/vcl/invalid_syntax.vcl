sub vcl_recv {
  if (!req.http.Accept-Encoding) {
    error 600
  }
#FASTLY recv
}

sub vcl_fetch {
#FASTLY fetch

}

sub vcl_hit {
#FASTLY hit
}

sub vcl_miss {
#FASTLY miss
}

sub vcl_deliver {
#FASTLY deliver
  return(deliver);
}

sub vcl_error {
#FASTLY error
}

sub vcl_pass {
#FASTLY pass
}

sub vcl_log {
#FASTLY log
}
