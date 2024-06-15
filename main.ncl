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
         <!-- <importBase   alias="conn"   documentURI="connBase.ncl"/> -->
      </connectorBase>
      <regionBase>
         <region id="mainRegion" left="0" top="0" width="100%" height="100%"/>
         <region id="searchRegion" left="0" top="0" width="100%" height="10%"/>
         <region id="resultsRegion" left="0" top="10%" width="100%" height="45%"/>
         <region id="detailsRegion" left="0" top="55%" width="100%" height="45%"/>
         <region id="videoRegion" left="0" top="55%" width="100%" height="45%" zIndex="1"/>
      </regionBase>
      <descriptorBase>
         <descriptor id="dVideo" region="videoRegion"/>
         <descriptor id="dmain" region="mainRegion"/>
         <descriptor id="dresult" region="resultsRegion"/>
         <descriptor id="dsearch" region="searchRegion" focusIndex="inputIdx"/>
         <descriptor id="ddetails" region="detailsRegion"/>
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
         </media>
        <media id="detailsField" src="details.lua" type="application/x-ginga-NCLua" descriptor="ddetails"/>
        <media id="videoPlayer_" descriptor="dVideo" src="media/abertura.mp4"/>

        <port id="psearch" component="searchField"/>
        <!-- <port id="presult" component="resultsField"/>-->
        <!-- <port id="pdetails" component="detailsField"/> -->

      <link xconnector="onBeginStart">
         <bind role="onBegin" component="searchField"/>
         <bind role="start"   component="resultsField"/>
         <bind role="start"   component="detailsField"/>
      </link>

      <link xconnector="onBeginSet">
         <bind role="onBegin" component="searchField" interface="select"/>
         <bind role="set" component="resultsField" interface="search">
            <bindParam name="var" value="$get"/>
         </bind>
         <bind role="get" component="searchField" interface="text"/>
      </link>

    </body>
</ncl>
