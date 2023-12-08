include "blocked_urls";

sub vcl_recv {
  if (table.contains(blocked_urls, req.url)) {
    error 603;
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
  if (obj.status == 603) {
    set obj.status = 403;
    set obj.response = "Forbidden";
  }
#FASTLY error
}

sub vcl_pass {
#FASTLY pass
}

sub vcl_log {
#FASTLY log
}
