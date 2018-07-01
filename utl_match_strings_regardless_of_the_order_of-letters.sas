Match strings regardless of the order of letters

see further insights on end
Paul Dorfman
Keintz, Mark via listserv.uga.edu
Bartosz Jablonski via listserv.uga.edu

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


see further insights on end
Paul Dorfman
Keintz, Mark via listserv.uga.edu
Bartosz Jablonski via listserv.uga.edu

*____    __  __   ____
|  _ \  |  \/  | | __ )
| |_) | | |\/| | |  _ \
|  __/  | |  | | | |_) |
|_|     |_|  |_| |____/

;


Paul Dorfman <sashole@bellsouth.net>
12:13 AM (17 hours ago)
 to SAS-L, me
Welcome, Roger.

I've neglected to mention that there's another algorithm for matching strings of
this nature in this manner ... let's call it, provisionally, the "string attrition"
method. I'll illustrate it in a simple step below; you'll infer the rest. Essentially, the scheme is:

1. Make a copy STR of the BASE string .
2. Get the first/next character from the COMP string.
3. If this character is in STR, replace its leftmost occurrence with a blank.
4. if we haven't gotten to the end of COMP, go to #2.
5. Otherwise if STR is blank, we've got a match.

In the SAS language:

data _null_ ;
  do base = "ABBCCCDDDD", "DDDDACCCBB" ;
    do comp = "DBCBCDDCDA", "XBBCCCDDDA", "BBCCCDDDAA", "BCCDADBDCD" ;
      str = base ;
      do _n_ = 1 to length (str) ;
        pos = findc (str, char (comp, _n_)) ;
        if pos then substr (str, pos, 1) = "" ;
      end ;
      match = missing (str) ;
      put base comp match ;
    end ;
  end ;
run ;

Log output:

ABBCCCDDDD DBCBCDDCDA 1 <-- Full match
ABBCCCDDDD XBBCCCDDDA 0 <-- X is not in BASE
ABBCCCDDDD BBCCCDDDAA 0 <-- Extra A in COMP
ABBCCCDDDD BCCDADBDCD 1 <-- Full match
DDDDACCCBB DBCBCDDCDA 1 <-- Full match
DDDDACCCBB XBBCCCDDDA 0 <-- X is not in BASE
DDDDACCCBB BBCCCDDDAA 0 <-- Extra A in COMP
DDDDACCCBB BCCDADBDCD 1 <-- Full match

Because of the pseudo SUBSTR function, this method is likely is not as
speedy as other techniques. Plus, unlike other techniques, it requires
comparing all BASE to all COMP. However, it there were a fast SAS function
implementing this scheme in the underlying software, it could be used to match
permuted strings directly - for example, via SQL. It would simply have two arguments: On
e for BASE and the other - for COMP.

Best regards,

Paul Dorfman




Keintz, Mark via listserv.uga.edu
12:54 AM (16 hours ago)
 to SAS-L
Paul:

You may very well want to promote the MD5 version of your frequency pattern
technique, for scalability in SAS's globalized market.  Once you get DBCS or
UTF8 text, I guess you need to use the (probably-slower) sortkey function
instead of call sortc, making the frequency alternative more attractive.

True, you'll be peeking much bigger lengths than 26*8.  In fact, you'll
need multiple MD5 results once you start tracking 4,096 or more frequencies,
since (I believe) MD5 only takes up to a 32,767 byte argument, while full
 UTF8 accommodates 1,112,064 code points.

And you won't want to depend on the data step loop to reset all those
frequencies, given only a relative few would be non-zero.
Tracking and resetting the non-zeroes would likely be the efficacious approach.

Now that's what I call job security.

Regards,
Mark


Keintz, Mark via listserv.uga.edu
12:58 AM (16 hours ago)
 to SAS-L
Paul:

Well I see while I was writing the note below, you described
the string-attenuation method, making concerns about UTF8 moot.

Regards,
Mark


Paul Dorfman            1:58 AM (15 hours ago)
Mark, Thanks. It's not unusual to have a rather clear afterthought after post...

Paul Dorfman            2:05 AM (15 hours ago)
Mark, Thanks. Your points, particularly about the cleaning of the freq storag...

Rick Wicklin            6:10 AM (11 hours ago)
Perhaps I am misunderstanding Roger's wish, but SAS has the SCAN and SUBSTR f...

Roger DeAngelis            10:43 AM (7 hours ago)
Good Point Rick But it can't in one call load a predefined array(vector) with...

Rick Wicklin            11:39 AM (6 hours ago)
1. In SAS/IML, it certainly can because the operation is vectorized: proc iml...

Roger DeAngelis            11:53 AM (5 hours ago)
Hi Rick Nice to know it is vectorized in IML. Thanks, I did not know that. Ca...

Paul Dorfman via listserv.uga.edu
3:59 PM (1 hour ago)
 to SAS-L
Rick,

In Base, it can also be both vectorized and de-vectorized en masse by using
the APP (ADDR/PEEK/POKE) set of functions/routines without the need to go 1
byte at a time. I demoed it first right here on SAS-L as far back as circa
1999-2000. As there's much more that can be done with this kind of functionality,
I've since given talks about it at various SUGs (first - with Peter Crawfor
d at SUGI in Montreal) at least 3-4 times. See the step below and note the
differences in the execution times. For N=1E7 test repetitions,
it prints the following in the log (X64_7PRO):

S-2-A CHAR   time: 12.55900  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
S-2-A APP    time:  1.20800  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
A-2-S SUBSTR time: 14.47200  ABCDEFGHIJKLMNOPQRSTUVWXYZ
A-2-S APP    time:  2.32000  ABCDEFGHIJKLMNOPQRSTUVWXYZ

The differences are actually much bigger on 32-bit machines where much quicker A
DDR/PEEK/POKE functions can be used instead of their "long" counterparts.

data _null_ ;
  retain s "ABCDEFGHIJKLMNOPQRSTUVWXYZ" N 1E7 ;
  array c [26] $ 1 ;
  d = dim (c) ;
  _a1 = addrlong (c[1]) ;
  _as = addrlong (s) ;

  /* string into array CHAR */
  call missing (of c[*]) ;
  t = time() ;
  do _n_ = 1 to N ;
    do i = 1 to d ;
      c[i] = char (s, i) ;
    end ;
  end ;
  time = time() - t ;
  put "S-2-A CHAR   time: " time 8.5 @30 (c[*]) (:) ;

  /* string into array ADDR/POKE */
  call missing (of c[*]) ;
  t = time() ;
  do _n_ = 1 to N ;
    call pokelong (s, _a1, d) ;
  end ;
  time = time() - t ;
  put "S-2-A APP    time: " time 8.5 @30 (c[*]) (:) ;

  /* array into string SUBSTR */
  call missing (s) ;
  t = time() ;
  do _n_ = 1 to N ;
    do i = 1 to d ;
      substr (s, i, 1) = c[i] ;
    end ;
  end ;
  time = time() - t ;
  put "A-2-S SUBSTR time: " time 8.5 @30 s ;

  /* array into string ADDR/PEEK/POKE */
  call missing (s) ;
  t = time() ;
  do _n_ = 1 to N ;
    call pokelong (peekclong (_a1, d), _as, d) ;
  end ;
  time = time() - t ;
  put "A-2-S APP    time: " time 8.5 @30 s ;
run ;

Best regards,

Paul Dorfman




From: Rick Wicklin <rick.wicklin@SAS.COM>
To: SAS-L@LISTSERV.UGA.EDU
Sent: Sunday, July 1, 2018 11:39 AM
Subject: Re: Stackoverflow:Match strings regardless of the order of letters


Bartosz Jablonski via listserv.uga.edu
4:11 PM (1 hour ago)
 to SAS-L
Hi Paul,

Your mail gave me an inspiration to test one more approach. Please let me share it:

I build it on following algebraic statement (it is nor 100% formal but give the esence):
"in binary comutative free algebra (X, *) over some alphabet X={A, B, C,...},
two words are equal if their normal forms are equal". Basicly if I have alphabet
{A, B, C} and two words: $A*A*B*B*C$ and $A*A*C*C*B$ I'm converting them to their
normal forms: $A^2B^2C$ and $A^2BC^2$ and then compare
 them, if normal forms are the same, words are the same.

I wraped the code into a FCMP subroutine to make it more userfriendly.

1) two strings are compared, if they have different klenghts[for utf-8]
then words are different,
2) hash table is declared, "Keys" are letters from compared words and
"Data" are numbers of occurences of a given letter in a word
3) first word is read into hash table, if some letter occures first time
then counter C is set to 1 and if letter occures next time the counter C
is increased
4) second word is read into hash, but if some letter is not found in the
hash[find() ^= 0] then words are different, if letter is found in the
hash then the counter C is decreased
5) hash iterator loops throught hash data and if at lesat one C is not
0 then words are different

her is the code:

options cmplib = _null_;

proc fcmp outlib = work.f.f;

subroutine comparewords(A $, B $, areequal);
outargs areequal;

areequal = 0;
LA = klength(A);
LB = klength(B);

if LA ^= LB then return;

length X $ 4 C 8;
declare hash WORD();
_rc_ = WORD.DefineKey("X");
_rc_ = WORD.DefineData("C");
_rc_ = WORD.DefineDone();
_rc_ = WORD.clear();

do _i_ = 1 to LA;
    X = ksubstr(A, _i_, 1);
    if 0 ^= WORD.find() then
    do;
        C = 1; _rc_ = WORD.add();
        /*put A= B= areequal= X= C= ;*/
    end;
    else
    do;
        C = C + 1; _rc_ = WORD.replace();
        /*put A= B= areequal= X= C= ;*/
    end;
end;


do _i_ = 1 to LB;
    X = ksubstr(B, _i_, 1);
    if 0 ^= WORD.find() then
    do;
       /*put "RETURN:" A= B= areequal= X= C= ;*/
       return;
    end;
    else
    do;
        C = C - 1; _rc_ = WORD.replace();
        /*put A= B= areequal= X= C= ;*/
    end;
end;

declare hiter iWORD('WORD');

_rc_ = iWORD.first();
do while(_rc_ = 0);
    if C then return;
    _rc_ = iWORD.next();
end;

areequal = 1;
_rc_ = WORD.clear();
return;
endsub;

run; quit;

options cmplib = work.f;


data _null_ ;
  do base = "ABBCCCDDDD", "DDDDACCCBB" ;
    do comp = "DBCBCDDCDA", "XBBCCCDDDA", "BBCCCDDDAA", "BCCDADBDCD" ;
        areequal = 0;
        call comparewords(base, comp, areequal);
        put _all_;
    end;
  end;

run;


all the best
Bart


Paul Dorfman via listserv.uga.edu
5:14 PM (35 minutes ago)
 to SAS-L
Hey Bart,

Bardzo madry! Very clever, indeed. You could work with Rejewski et al.
in Biuro Szyfrów if you were a bit younger ;). Essentially, you've adapted
 hash storage to maintain the attrition bookkeeping. And thank you for wrapping
it into a call routine - something I admit I must devote more time to master properly.

Best regards
Paul Dorfman


From: Bartosz Jablonski <yabwon@gmail.com>
To: Paul Dorfman <sashole@bellsouth.net>
Cc: "SAS-L@LISTSERV.UGA.EDU" <SAS-L@listserv.uga.edu>
Sent: Sunday, July 1, 2018 4:11 PM
Subject: Re: Stackoverflow:Match strings regardless of the order of letters


Roger DeAngelis <rogerjdeangelis@gmail.com>
5:46 PM (3 minutes ago)
to Paul, SAS-L
Paul you are correct and the performance should be competitive with other 'vectorized' solutions, but
it a bit more code. There is also an issue that only temporary arrays have back to back data,
not a problem parsing a string less than 'pagesize'?

  addr/peek/poke
      Array cs c1-c4;
     _a1 = addrlong (c[1])
     call pokelong ("ABCD", _a1, 4) ;

   * maybe future functionality.
   * less code - slightly more readable;

   array cs c1-c4;
   call strsplit('ABCD',cs,1);


I wrote a %common macro that could share storage with dosubl and it also supports 'verctorized' processing.
It uses add/peek and poks

data want;

  array xs x1-x10;
  %common xs;
  rc=dosubl('
     data sub;
        %common xs; * arguments must match;
        reading and writing to xs changes xs in the parent



