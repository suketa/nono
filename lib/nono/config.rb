module Nono
  module Config
    X = 1
    Y = 2
    BLANK = '  '
    DEFAULT_COLOR='X'
    MAX_TIMES = 50
    DEFAULT_COLOR_CSS = 'X=black'

    HTML_TEMPLATE=<<HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=ISO-8859-1"> 
<META HTTP-EQUIV="CONTENT-STYLE-TYPE" CONTENT="text/css">
<style type="text/css">
<!--
body {background-color: white;}
table {border-width: 1em;}
td {width: 1em; height: 1em; border-style:solid; border-width:1px; border-color: black;} 
td.SP {border-color: white;}
<%= td_color_style %>
-->
</style>
<title>answer</title>
</head>

<body>
<p>
<%= @file %>&nbsp;
<%= msg %>
</p>
<table cellpadding="0" cellspacing="0">
<%= answer %>
</table>
</body>
</html>
HTML
  end
end
