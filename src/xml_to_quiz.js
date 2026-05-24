//
//indx#	xml_to_quiz.js - (VERY brief explanation of what this file is/does)
//@HDR@	$Id$
//@HDR@
//@HDR@	Copyright (c) 2026 Christopher Caldwell (Christopher.M.Caldwell0@gmail.com)
//@HDR@
//@HDR@	Permission is hereby granted, free of charge, to any person
//@HDR@	obtaining a copy of this software and associated documentation
//@HDR@	files (the "Software"), to deal in the Software without
//@HDR@	restriction, including without limitation the rights to use,
//@HDR@	copy, modify, merge, publish, distribute, sublicense, and/or
//@HDR@	sell copies of the Software, and to permit persons to whom
//@HDR@	the Software is furnished to do so, subject to the following
//@HDR@	conditions:
//@HDR@	
//@HDR@	The above copyright notice and this permission notice shall be
//@HDR@	included in all copies or substantial portions of the Software.
//@HDR@	
//@HDR@	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
//@HDR@	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//@HDR@	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
//@HDR@	AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//@HDR@	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//@HDR@	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//@HDR@	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
//@HDR@	OR OTHER DEALINGS IN THE SOFTWARE.
//
//hist#	2026-05-24 - Christopher.M.Caldwell0@gmail.com - Created
////////////////////////////////////////////////////////////////////////
//doc#	(Less brief explanation of what this file is/does)
////////////////////////////////////////////////////////////////////////
<!doctype html><html lang=en>
<head>
<script language=JavaScript>
//indx#	xml_to_quiz.js - (VERY brief explanation of what this file is/does)
//
//hist#	2026-05-24 - Christopher.M.Caldwell0@gmail.com - Created
////////////////////////////////////////////////////////////////////////
//doc#	(Less brief explanation of what this file is/does)
////////////////////////////////////////////////////////////////////////
var conceptcolor	= "#d0d080";
var rightcolor		= "#c0f0c0";
var wrongcolor		= "#a0a0a0";
var answercolor		= "#80a0c0";
var questioncolor	= "#b0b0b0";
var uniquename	= "[UNIQUENAME]";
var qa		= new Array([QUESTIONS]);
var sections	= new Array([SECTIONS]);
var concepts	= new Array([CONCEPTS]);
var seenconcepts= new Array();

var quiz_mode = 1;
var seen_val = String("");
var cur_question = 0;
var rlpieces;
var rli = 0;
var number_answers = 0;
var really_small = ( /iPhone/.test( navigator.userAgent ) );

var hidden_flag = 0;
var hiders = [ "toggle_line", "hide_button", "left_toggle", "right_toggle" ];
var unhiders = [ "unhide_button" ];

function update_hidden()
    {
    var i;
    for( i=0; i<hiders.length; i++ )
        {
	document.getElementById( hiders[i] ).style.display
	    = ( hidden_flag ? "none" : "" );
	}
    for( i=0; i<unhiders.length; i++ )
        {
	document.getElementById( unhiders[i] ).style.display
	    = ( hidden_flag ? "" : "none" );
	}
    }

var elements = new Array("p","table","td","th","div","input","button","font");
var element_sizes = new Array();
function font_size( s )
    {
    var el;
    for( e=0; e<elements.length; e++ )
	{
	var p = document.getElementsByTagName( elements[e] );
	if( p )
	    {
	    var n;
	    for( n=0; n<p.length; n++ )
		{
		if( ! p[n].style.fontSize )
		    {
		    if( element_sizes[e] )
		        { p[n].style.fontSize=element_sizes[e]; }
		    else
		        { p[n].style.fontSize="12px"; }
		    }
		var sz = parseInt(p[n].style.fontSize.replace("px","")) + s;
		sz += s;
		p[n].style.fontSize = sz + "px";
		element_sizes[e] = sz;
		}
	    }
	}
    }

function genran(mx)
    {
    return Math.floor( Math.random() * mx );
    }

function randomize_lists( base )
    {
    var toalter = base;
    while( /^(.*?)<\/rl>(.*)$/.test( toalter ) )
        {
	var before = "";
	var toparse = RegExp.$1;
	var after = RegExp.$2;
	while( /^(.*<rl.*)(<rl.*)$/.test( toparse ) )
	    {
	    before += RegExp.$1;
	    toparse = RegExp.$2;
	    }
	if( /(.*)<(rl[^>]*)>(.*)/.test(toparse) )
	    {
	    before += RegExp.$1;
	    var rlargs = RegExp.$2;
	    var onelist = RegExp.$3;
	    var rllist = rlargs.split(" ");
	    var sep = "";
	    var commamode = 0;
	    var i;
	    for( i=0; i<rllist.length; i++ )
	        {
		if( /sep=(.*)/.test( rllist[i] ) )
		    { sep = RegExp.$1; }
		else if( rllist[i] == "commamode" )
		    { commamode = 1; }
		else if( /commamode=(.*)/.test(rllist[i]) )
		    { commamode = RegExp.$1; }
		}
	    var listitems = onelist.split("<li>");
	    var toadd = ( listitems[0] + (commamode?"":"<ul>") );
	    while( listitems.length > 1 )
	        {
		var pickone = genran( listitems.length-1 ) + 1;
		var toprt = listitems[pickone];
		if( /^(.*[^\s])\s*$/.test(toprt) )
		    { toprt = RegExp.$1; }
		toadd += ((commamode?"":"<li parsed>") + toprt);
		listitems[pickone] = listitems[ listitems.length - 1];
		listitems.length--;
		if( commamode )
		    {
		    if( listitems.length > 2 )
		        { toadd += ", "; }
		    else if( listitems.length == 2 )
		        { toadd += " " + ( sep ? sep : "and") + " "; }
		    }
		else if( listitems.length==2 && sep )
		    { toadd += ("<br>&nbsp;" + sep); }
		}
	    toalter = before + toadd + (commamode?"":"</ul>") + after;
	    }
	}
    return toalter;
    }

function put_up_question( ind, colflag )
    {
    var i, j;
    var parts = qa[ind].split("%%");
    var qbase = 0;
    var concept = parts[qbase++];
    var section = parts[qbase++];
    var quest = parts[qbase++];
    var explanation = parts[qbase++];
    var qtable = "<table border=1>";
    var right = 0;
    for( i=0; i<qa.length; i++ )
        {
	var r = seen_val.charAt(i);
	if( r!="" && r!="0" ) { right++; }
	}
    document.getElementById("SCORE").innerHTML =
        "<table width=100%><tr><th width=1>" +
	"<input type=button value=Next onClick='transition(1);'>" +
	"</th><th align=center>" +
	right + " right out of " + i + " or " + Math.floor(100*right/i) +"%" +
	"</th><th width=1>" +
	"<input type=button id=hide_button value=Hide" +
	    ( hidden_flag ? " style='display:none'" : "" ) +
	    " onClick='hidden_flag=1;update_hidden();'>" +
	"<input type=button id=unhide_button value=Unhide" +
	    ( hidden_flag ? "" : " style='display:none'" ) +
	    " onClick='hidden_flag=0;update_hidden();'>" +
	"</th></tr></table>";
    if( concept >= 0 && ! quiz_mode && ! seenconcepts[concept] )
        {
	seenconcepts[concept] = 1;
	qtable += ("<tr><td bgcolor="+conceptcolor+">"+concepts[concept]+"</td></tr>");
	window.document.form.answerbutton.value = "Start questions";
	}
    else
	{
	if( section >= 0 )
	    {
	    qtable += ("<tr><td bgcolor="+questioncolor+">" +
			    sections[section] +
			    "</td></tr></table><table border=1>" );
	    }
	qtable += "<tr><td bgcolor=#809080><font size=+2>";
	qtable += randomize_lists(quest);
	qtable += "</font>";
	number_answers = parts.length - qbase;
	if( (number_answers <= 1) && colflag )
	    {
	    qtable += ("</td></tr><tr><td bgcolor="+rightcolor+">"+
			"<font size=+2>" +
	    		randomize_lists(parts[qbase])+"</font></td></tr>");
	    }
	else if( number_answers > 1 )
	    {
	    var order = new Array( number_answers );
	    for( i=0; i<number_answers; i++ )
		{
		var rv = genran(number_answers);
		for( j=0; j<i; j++ )
		    {
		    if( order[j] == rv )
			{
			j=-1;
			rv = genran(number_answers);
			}
		    }
		order[i] = rv;
		}
	    qtable += "<center><p>";
	    if( really_small ) { qtable += "<table width=90%>"; }
	    for( i=0; i<number_answers; i++ )
		{
		j = order[i];
		var colcode = answercolor;
		if( i > 0 ) qtable+="<br>"
		if( colflag ) colcode = ( (j==0) ? rightcolor : wrongcolor );
		if( really_small )
		    {
		    var butstr = "<button style='width:90;height=90%'";
		    butstr+= (j ? " onClick='wrong(this);'" : "onClick='right();'");
		    butstr += "> </button>";
		    qtable += "<tr><th width=10%>";
		    if( i%2 == 0 ) { qtable += butstr; }
		    qtable += "</th><th width=80% bgcolor="+colcode+">";
		    qtable += randomize_lists(parts[j+qbase]);
		    qtable += "</th><th width=10%>";
		    if( i%2 == 1 ) { qtable += butstr; }
		    qtable += "</th></tr>";
		    }
		else
		    {
		    qtable+="<button style='width:90%;Background-Color:"+colcode+"'";
		    qtable+= (j ? " onClick='wrong(this);'" : "onClick='right();'");
		    qtable+=(">"+randomize_lists(parts[j+qbase])+"</button>");
		    }
		}
	    if( really_small ) { qtable += "</table>"; }
	    qtable += "<p></center></td></tr>";
	    }
	if( colflag )
	    {
	    if( explanation != "" )
		{
		qtable+=
		    ("</table><table border=1><tr><td bgcolor=" +
			    conceptcolor+">"+explanation+"</td></tr>");
		}
	    else if( concept >= 0 )
		{
		qtable+=
		    ("</table><table border=1><tr><td bgcolor=" +
			    conceptcolor+">"+concepts[concept]+"</td></tr>");
		}
	    }
	}
    qtable += "</table>";
    document.getElementById("QUESTIONTABLE").innerHTML = qtable;
    font_size( 0 );
    }

function read_cookie()
    {
    var cookievar = document.cookie.split("; ");
    for( i=0; i<cookievar.length; i++ )
        {
	if( cookievar[i].split("=")[0] == uniquename )
	    {
	    var cval = cookievar[i].split("=")[1];
	    var cookietoks = cval.split(":");

	    cur_question = parseInt( cookietoks[0] );
	    quiz_mode = parseInt( cookietoks[1] );
	    seen_val = cookietoks[2];
	    }
	}
    }

function update_cookie()
    {
    expiredate = new Date;
    expiredate.setMonth(expiredate.getMonth()+6);
    var newcookie = cur_question+":"+quiz_mode+":"+seen_val;
    document.cookie = uniquename+"="+newcookie+
        ";expires="+expiredate.toGMTString();
    }

function get_seen(sectval)
    {
    if( seen_val == "" )
        {
	var ctr = qa.length;
	while( ctr-- > 0 )
	    {
	    seen_val += "0";
	    }
	}
    return parseInt( seen_val.charAt(sectval) );
    }

function put_seen(sectval,v)
    {
    if( seen_val == "" )
        {
	var ctr = qa.length;
	while( ctr-- > 0 )
	    {
	    seen_val += "0";
	    }
	}
    var nv = new String("");
    var ctr;
    for( ctr=0; ctr<qa.length; ctr++ )
	{
        if( ctr == sectval )
	    {
	    nv += v;
	    }
	else if( seen_val == "" )
	    {
	    nv += "0";
	    }
	else
	    {
	    nv += seen_val.charAt(ctr);
	    }
	}
    seen_val = nv;
    update_cookie();
    }

function transition( offset )
    {
    with( window.document.form )
	{
	if( offset == 0 )
	    {
	    cur_question = question.value - 1;
	    put_seen( cur_question, 0 );
	    }
	else if ( quiz_mode )
	    {
	    var fac;
	    do  {
		cur_question = genran( qa.length );
		var numright = get_seen( cur_question );
		fac = 1;
		while( numright-- > 0 )
		    {
		    fac *= 3;
		    }
		} while( genran( fac ) > 0 );
	    }
	else
	    {
	    var ctr = qa.length;
	    do  {
		cur_question = (cur_question + offset + qa.length) % qa.length;
		if( ctr-- < 0 )
		    {
		    alert("All questions now complete.  Clearing history.");
		    clear_history();
		    }
		} while( get_seen(cur_question) );
	    }
	answerbutton.value = "Show answer";
	update_widgets();
	}
    put_up_question( cur_question, 0 );
    }

function clear_history()
    {
    seen_val = new String("");
    put_seen( 0, 0 );
    }

function update_widgets()
    {
    with( window.document.form )
        {
	for( var i=0; i<mode.length; i++ )
	    { mode[i].checked = ( i==quiz_mode ? 1 : 0 ); }
	question.value = cur_question + 1;
	}
    update_cookie();
    }

function set_mode(m)
    {
    quiz_mode = m;
    update_widgets();
    }

function inc_seen(offset)
    {
    var curval = get_seen( cur_question );
    if( curval<9 && offset>0 )
        { put_seen( cur_question, curval+1 ); }
    }

function wrong(t)
    {
    t.disabled = true;
    if( get_seen(cur_question) > 0 )
        { put_seen( cur_question, 0 ); }
    if( confirm("Wrong!  Show correct answer?") )
        { put_up_question( cur_question, 1 ); }
    }

function right()
    {
    inc_seen(1);
    transition(1);
    }

function answer()
    {
    with ( window.document.form )
        {
	if( answerbutton.value == "Start questions" )
	    {
	    answerbutton.value = "Show answer";
	    put_up_question( cur_question, 0 );
	    }
	else if( answerbutton.value == "Show answer" )
	    {
	    if( number_answers <= 1 )
	        { answerbutton.value = "Know it already"; }
	    else
	        { answerbutton.value = "Hide answer"; }
	    put_up_question( cur_question, 1 );
	    }
	else if( answerbutton.value == "Hide answer" )
	    {
	    answerbutton.value = "Show answer";
	    put_up_question( cur_question, 0 );
	    }
	else if( answerbutton.value == "Know it already" )
	    {
	    right();
	    }
	else
	    {
	    alert("Unknown answerbutton value:  "+answerbutton.value);
	    }
	}
    }

</script>
<style type="text/css">
<!--
input[type=button]
	{
	font-size:	smaller;
	}
button
	{
	font-size:	smaller;
	}
UL    { margin-top: 0; margin-bottom: 0 }
OL    { margin-top: 0; margin-bottom: 0 }
-->
</style>
</head>
<body bgcolor=#305070>
<form name=form onSubmit='return false;'><center>
<table><tr><th align=left id=left_toggle>
<input type=button onClick='font_size(-1);' value="-"><br
><input type=button onClick='font_size(01);' value="+"></th>
<th align=center width=100%>
<table border=1 cellspacing=0 cellpadding=3><tr id=toggle_line>
<th bgcolor=#6060a0>
<input type=text name=question size=4 onChange='transition(0);'>
of [NUMBER_QUESTIONS]
</th><th bgcolor=#6060a0 align=left>
    <input type=radio name=mode value=learn onClick='set_mode(0);'>
    <a href='javascript:alert("
Learn mode displays tutorial information (if available)\n
and then asks questions, one by one, in order.\n\n
It is useful for learning the answers to questions you have\n
never seen before.");'>Learn</a> mode<br>
    <input type=radio name=mode value=quiz checked onClick='set_mode(1);'>
    <a href='javascript:alert("
Quiz mode asks a random question from the list of questions.\n
The more times you answer the question correctly, the less likely\n
it is to ask you the question again.  Answering a question\n
incorrectly increases the probability of it being asked again.
");'>Quiz</a> mode<br>
</th><th bgcolor=#60a060>
<input type=button name=answerbutton value="Show answer" onClick='answer();'>
</th><th bgcolor=#a06060>
<input type=button value=Top onClick='window.location="index.html";'>
</th><th bgcolor=#a060a0>
<input type=button value="Forget history" onClick='clear_history();'>
</th></tr>
<tr><th colspan=5><div ID="SCORE">A score</div></th></tr>
</table>
</th><th align=right id=right_toggle>
<input type=button onClick='font_size(-1);' value="-"><br
><input type=button onClick='font_size(01);' value="+"></th>
</tr></table>
<DIV ID="QUESTIONTABLE">
Something to replace
</DIV>
</center>
</form>
<script language=JavaScript>
read_cookie();
update_widgets();
put_up_question( cur_question, 0 );
</script>
</body>
</html>
