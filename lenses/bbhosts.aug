(* BB-hosts module for Augeas                 *)
(* Author: Raphael Pinson <raphink@gmail.com> *)
(*                                            *)
(* Supported :                                *)
(*                                            *)
(* Todo :                                     *)
(*                                            *)

module BBhosts =
    autoload xfm

    (* Define useful shortcuts *)

    let eol = Util.eol
    let eol_no_spc = Util.del_str "\n"
    let sep_spc = Sep.space
    let sep_opt_spc = Sep.opt_space
    let word  = store /[^|;# \n\t]+/
    let value_to_eol = store /[^ \t][^\n]+/
    let ip    = store Rx.ipv4
    let url   = store /https?:[^# \n\t]+/
    let word_cont = store /[^;# \n\t]+/

    (* Define comments and empty lines *)
    let comment = Util.comment
    let empty   = Util.empty


    (* Define host *)
    let host_ip   = [ label "ip" . ip ]
    let host_fqdn = [ label "fqdn" . sep_spc . word ]

    let host_test_url  = [ label "url" . url ]
    let host_test_cont (kw:string) = [ store /!?/ . key kw .
                             (Util.del_str ";" .
                                [ label "url" . word_cont ] .
			        (Util.del_str ";" . [ label "keyword" . word ])?
			     )?
			     ]

    let host_test_flag_value = [ label "value" . Util.del_str ":"
                              . store Rx.word ]

    let host_test_flag (kw:string) = [ store /!?/ . key kw
                                     . host_test_flag_value? ]

    let host_test = host_test_cont "cont"
                  | host_test_cont "contInsecure"
                  | host_test_cont "dns"
                  | host_test_flag "CDB"
                  | host_test_flag "ftp"
                  | host_test_flag "front"
                  | host_test_flag "GTM"
		  | host_test_flag "noping"
		  | host_test_flag "noconn"
		  | host_test_flag "ssh"
		  | host_test_flag "ssh2"
		  | host_test_flag "smtp"
		  | host_test_flag "pop3"
		  | host_test_flag "imap2"
		  | host_test_flag "telnet"
		  | host_test_flag "BBDISPLAY"
		  | host_test_flag "BBNET"
		  | host_test_flag "BBPAGER"
		  | host_test_flag "XYMON"
                  | host_test_url


    let host_test_list = Build.opt_list host_test sep_spc

    let host_opts = [ label "probes" . sep_spc . Util.del_str "#" . (sep_opt_spc . host_test_list)? ]

    let host = [ label "host" . host_ip . host_fqdn . host_opts . eol ]

    (* Define group-compress and group-only *)
    let group_compress = [ key /group(-compress)?/ . (sep_spc . value_to_eol)? . eol_no_spc .
                  ( comment | empty | host)*
		  ]

    let group_only_col  = [ label "col" . word ]
    let group_only_cols = sep_spc . group_only_col . ( Util.del_str "|" . group_only_col )*
    let group_only      = [ key "group-only" . group_only_cols . sep_spc . value_to_eol . eol_no_spc .
                  ( comment | empty | host)*
		  ]


    (* Define page *)
    let page_title = [ label "title" . sep_spc . value_to_eol ]
    let page = [ key "page" . sep_spc . word . page_title? . eol_no_spc .
                  ( comment | empty | host )* . ( group_compress | group_only )*
		  ]


    (* Define lens *)

    let lns = (comment | empty)* . page*

    let filter = incl "/etc/bb/bb-hosts"
               . Util.stdexcl

    let xfm = transform lns filter

