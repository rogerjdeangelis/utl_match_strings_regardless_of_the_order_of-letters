# utl_match_strings_regardless_of_the_order_of-letters
Match strings regardless of the order of letters.  Keywords: sas sql join merge big data analytics macros oracle teradata mysql sas communities stackoverflow statistics artificial inteligence AI Python R Java Javascript WPS Matlab SPSS Scala Perl C C# Excel MS Access JSON graphics maps NLP natural language processing machine learning igraph DOSUBL DOW loop stackoverflow SAS community.
    Match strings regardless of the order of letters

    see github
    https://tinyurl.com/ydd78z6z
    https://github.com/rogerjdeangelis/utl_match_strings_regardless_of_the_order_of-letters

    inspired by
    https://tinyurl.com/yc8tsfmy
    https://stackoverflow.com/questions/51092283/find-strings-that-contain-a-sequence-of-characters-regardless-of-the-order-in-r

    INPUT
    =====

      Match

       CBC
       ABB

      To      |  RULE      WANT
              |
       BCC    |  Matches   CBC
       CAB    |  NO MATCH
       ABB    |  Matches   ABB
       CBC    |  Matches   CBC
       CCB    |  Matches   CBC
       BAB    |  Matches   ABB
       CDB    |  NO MATCH


     EXAMPLE OUTPUT

     The five matches ( 2 records do not match)

               Ordered
    Original   Original    Match
     String     String    String

     1  BCC     BCC          CBC
     2  ABB     ABB          ABB
     3  CBC     BCC          CBC
     4  BCC     BCC          CCB
     5  ABB     ABB          BAB


    PROCESS
    ========

    data want;

      retain havOrd;

      * Use aview to sort string into alphabetical order;
      if _n_=0 then do;
         %let rc=%sysfunc(dosubl('

            data havOrd/view=havOrd;
              set have;
              havRaw=cats(of s:);
              call sortc(of s:);
              havOrd=cats(of s:);
              drop s:;
            run;quit;

            data fndOrd/view=fndOrd;
              set find;
              call sortc(of t:);
              fndOrd=cats(of t:);
              drop t:;
            run;quit;

         '));
      end;

      * very simple elegant hash;
      if _n_=1 then do;

        if 0 then set fndOrd;
        declare hash h(dataset: 'fndOrd');
        h.definekey('fndOrd');
        h.definedone();

      end;

      set havOrd;
      if h.find(key:havOrd) eq 0 then output;

    run;quit;


    OUTPUT
    ======

    WORK.WANT total obs=5

      HAVORD    FNDORD    HAVRAW

       BCC       BCC       BCC
       ABB       ABB       ABB
       BCC       BCC       CBC
       BCC       BCC       CCB
       ABB       ABB       BAB


    *                _              _       _
     _ __ ___   __ _| | _____    __| | __ _| |_ __ _
    | '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
    | | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
    |_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

    ;

    data have;
      input (s1 s2 s3) ($1.);
    cards4;
    BCC
    CAB
    ABB
    CBC
    CCB
    BAB
    CDB
    ;;;;
    run;quit;

    data find;
      input (t1 t2 t3) ($1.);
    cards4;
    CBC
    ABB
    ;;;;
    run;quit;

    *          _       _   _
     ___  ___ | |_   _| |_(_) ___  _ __
    / __|/ _ \| | | | | __| |/ _ \| '_ \
    \__ \ (_) | | |_| | |_| | (_) | | | |
    |___/\___/|_|\__,_|\__|_|\___/|_| |_|

    ;

    see process;

