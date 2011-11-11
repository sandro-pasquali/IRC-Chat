var _ = {};

_.brk     = "<br>";
_.lbr     = "******************************************************",
_.cursor  = "* ",
_.header  = _.lbr + _.brk + _.cursor + _.brk;
_.footer  = _.cursor + _.brk + _.lbr + _.brk;

_.login = 
  [
    "+ WELCOME! +",
    "",
    "Please be nice. We don't want to ban anyone"
  ];

_.warnings = 
  {
    JOIN_WITH_EXISTING_NICK: 
      [
        'Someone is already logged in with that username.  If you feel this is an error, <a href="asfunction:_root.support(%%)"><u>CLICK HERE</u></a> to report this problem to our support staff.'
      ],
      
    OUT_OF_CREDITS: 
      [
        'You have run out of credits.'
      ],
      
    GENERAL_BOOT: 
      [
        'You have been booted from the room.'
      ]
  };

_.help = 
  {
    about:
      [
        "+ ABOUT THIS CHAT +",
        "",
        "Here is where you write info about the chat"
      ],
      
    rules:
      [
        "+ RULES AND GUIDELINES +",
        "",
        "These are the rules for this chat:",
        "",
        "1. No abusive language.",
        "2. No spamming.",
        "3. Etc."
      ],
      
    commands:
      [
        "+ EXTENDED COMMANDS +",
        "",
        "/msg [nickname] [message]",
        "usage: /msg john Hi John!",
        "action: This will send a private [message] from you to [nickname].",
        "variants: /m",
        "",
        "/help [category]",
        "usage: /help commands",
        "action: displays help file for [category].",
        "variants: /h",
        "",
        "/time",
        "usage: /help",
        "action: shows current server date and time.",
        "variants: /date /t /d",
        "",
        "/clear",
        "usage: /clear",
        "action: clears the screen of all previous chatter.",
        "variants: /c"
      ]
  };