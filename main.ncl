<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
    <head>
      <!-- <meta>
         <name>Recipe Search App</name>
      </meta> -->
      <connectorBase>
         <causalConnector id="onBeginStart">
            <simpleCondition role="onBegin"/>
            <simpleAction role="start"/>
         </causalConnector>
         <causalConnector id="onBeginSet">
            <connectorParam name="var"/>
            <simpleCondition role="onBegin"/>
            <simpleAction role="set" value="$var"/>
         </causalConnector>

         <causalConnector id="onKeySelectionStart">
            <connectorParam name="aKey"/>
            <simpleCondition role="onSelection" key="$aKey"/>
            <simpleAction role="start"/>
         </causalConnector>

         <causalConnector id="onKeySelectionSet">
            <connectorParam name="aKey"/>
            <connectorParam name="var"/>
            <simpleCondition role="onSelection" key="$aKey"/>
            <simpleAction role="set" value="$var"/>
         </causalConnector>
         <causalConnector id="onEndAttributionSet">
            <connectorParam name="var"/>
            <simpleCondition role="onEndAttribution"/>
            <simpleAction role="set" value="$var"/>f
         </causalConnector>

         <!-- <importBase   alias="conn"   documentURI="connBase.ncl"/> -->
      </connectorBase>
      <regionBase>
         <region id="mainRegion" left="0" top="0" width="100%" height="100%" />
         <region id="searchRegion" left="0" top="0" width="100%" height="10%"/>
         <region id="resultsRegion" left="0" top="10%" width="100%" height="90%"/>
      </regionBase>
      <descriptorBase>
         <descriptor id="dmain" region="mainRegion" focusIndex="0"/>
         <descriptor id="dresult" region="resultsRegion" focusIndex="inputIdx"/>
         <descriptor id="dsearch" region="searchRegion" focusIndex="inputIdx"/>
      </descriptorBase>
    </head>
    <body>
      <media type="application/x-ginga-settings" id="programSettings">
         <property name="service.currentKeyMaster" value="inputIdx"/>
      </media>
        <media id="searchField" src="search.lua" type="application/x-ginga-NCLua" descriptor="dsearch">
            <area id="select"/>
            <property name="text"/>
         </media>
        <media id="resultsField" src="results.lua" type="application/x-ginga-NCLua" descriptor="dresult">
        		<property name="search"/>
		      <property name="result"/>
		      <property name="text"/>
         </media>

        <port id="psearch" component="searchField"/>
        <!-- <port id="presult" component="resultsField"/>-->
        <!-- <port id="pdetails" component="detailsField"/> -->

      <link xconnector="onBeginStart">
         <bind role="onBegin" component="searchField"/>
         <bind role="start"   component="resultsField"/>
      </link>

      <link xconnector="onKeySelectionSet">
         <bind role="onSelection" component="searchField">
            <bindParam name="akey" value="GREEN"/>
         </bind>
         <bind role="set" component="resultsField" interface="search">
            <bindParam name="var" value="$get"/>
         </bind>
         <bind role="get" component="searchField" interface="text"/>
      </link>
      <link xconnector="onEndAttributionSet">
         <bind role="onEndAttribution" component="resultsField" interface="result"/>
         <bind role="set" component="resultsField" interface="text">
            <bindParam name="var" value="$get"/>
         </bind>
         <bind role="get" component="resultsField" interface="result"/>
      </link>
    </body>
</ncl>
