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
         <descriptor id="dsearch" region="searchRegion"/>
         <descriptor id="ddetails" region="detailsRegion"/>
      </descriptorBase>
    </head>
    <body>
        <media id="searchField" src="search.lua" type="application/x-ginga-NCLua" descriptor="dsearch">
            <!-- <property name="searchEvent"/> -->
         </media>
        <media id="resultsField" src="results.lua" type="application/x-ginga-NCLua" descriptor="dresult"/>
        <media id="detailsField" src="details.lua" type="application/x-ginga-NCLua" descriptor="ddetails"/>
        <media id="videoPlayer_" descriptor="dVideo" src="media/abertura.mp4"/>

        <port id="psearch" component="searchField"/>
        <!-- <port id="presult" component="resultsField"/>-->
        <!-- <port id="pdetails" component="detailsField"/> -->
    </body>
</ncl>
