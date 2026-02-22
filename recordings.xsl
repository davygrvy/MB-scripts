<?xml version="1.0"?>
<!--

Call this from the commandline something like this:
wget -O - https://musicbrainz.org/ws/2/recording?work=36df44f5-7cad-37ee-9aae-89a5c58dfb07\&inc=artist-credits+event-rels+place-rels+area-rels+work-rels\&limit=25\&offset=850 |xsltproc -o recordings.html recordings.xsl -; google-chrome recordings.html

See https://musicbrainz.org/doc/MusicBrainz_API for details

-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:mb="http://musicbrainz.org/ns/mmd-2.0#">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <html>
    <body>
    <h2>MusicBrainz recording decoder test with auto-gen by davygrvy@pobox.com</h2>
    Count is <xsl:value-of select="mb:metadata/mb:recording-list/@count" /><br/>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>Title</th>
        <th>Artist</th>
        <th>Attributes</th>
        <th>Performance</th>
        <th>Auto-gen</th>
        <th>Disambig</th>
      </tr>
      <xsl:for-each select="mb:metadata/mb:recording-list/mb:recording">
        <tr>
          <!-- Title -->
          <td><a href="https://musicbrainz.org/recording/{@id}"><xsl:value-of select="mb:title"/></a></td>
          <!-- Artist -->
          <td><xsl:value-of select="mb:artist-credit/mb:name-credit/mb:artist/mb:name"/></td>
          <!-- Attributes (of first work) -->
          <td>
          <xsl:for-each select="mb:relation-list/mb:relation[@type-id='a3005666-a872-32c3-ad06-98af558e99b0'][1]/mb:attribute-list/mb:attribute">
             <nobr><xsl:value-of select="."/>
             <xsl:if test="position() != last()">
                <!-- Add the separator if it's not the last item -->
                <xsl:text> + </xsl:text>
             </xsl:if>
             </nobr><br/>
          </xsl:for-each>
          </td>
          <!-- Performance -->
          <xsl:choose>
             <!-- Any 'recorded at/in' attributes? -->
             <xsl:when test="not(mb:relation-list/mb:relation[
                                 @type-id='b06e6732-2603-47d3-8a49-9f589b430483' or
                                 @type-id='ad462279-14b0-4180-9b58-571d0eef7c51' or
                                 @type-id='354043e1-bdc2-4c7f-b338-2bf9c1d56e88'
                                 ])">
                <td>[no data]</td>
             </xsl:when>
             <xsl:otherwise>
                <td>
                <xsl:for-each select="mb:relation-list/mb:relation">           
                   <xsl:choose>
                      <xsl:when test="@type-id='b06e6732-2603-47d3-8a49-9f589b430483'">
                         <!-- 'recorded at' for event, but we can't see 'held in/at', so display name with link to event -->
                         
                         <nobr><a href="https://musicbrainz.org/event/{mb:event/@id}"><xsl:value-of select="mb:event/mb:name"/></a>
                         <!-- TODO: do range instead of just begin -->
                         (<xsl:value-of select="mb:event/mb:life-span/mb:begin"/>)
                         <xsl:if test="mb:event/mb:disambiguation">
                            [<xsl:value-of select="mb:event/mb:disambiguation"/>]
                         </xsl:if>
                         </nobr><br/>
                      </xsl:when>
                      
                      <xsl:when test="@type-id='ad462279-14b0-4180-9b58-571d0eef7c51'">
                         <!-- 'recorded at' for place -->
                         
                         <nobr>
                         <xsl:choose>
                            <xsl:when test="not(mb:target-credit)">
                               <xsl:value-of select="mb:place/mb:name"/>
                            </xsl:when>
                            <xsl:otherwise>
                               <!-- use 'credited as' when spec'd -->
                               <xsl:value-of select="mb:target-credit"/>
                            </xsl:otherwise>
                         </xsl:choose>
                         <!-- TODO: do range instead of just begin -->
                         <xsl:choose>
                            <xsl:when test="not(mb:begin)">
                               ([no date])
                            </xsl:when>
                            <xsl:otherwise>
                               (<xsl:value-of select="mb:begin"/>)
                            </xsl:otherwise>
                         </xsl:choose>
                         </nobr><br/>
                      </xsl:when>
                      
                      <xsl:when test="@type-id='37ef3a0c-cac3-4172-b09b-4ca98d2857fc'">
                         <!-- 'recorded in' for area -->
                         
                         <nobr>
                         <xsl:choose>
                            <xsl:when test="not(mb:target-credit)">
                               <xsl:value-of select="mb:area/mb:name"/>
                            </xsl:when>
                            <xsl:otherwise>
                               <!-- use 'credited as' when spec'd -->
                               <xsl:value-of select="mb:target-credit"/>
                            </xsl:otherwise>
                         </xsl:choose>
                         <!-- TODO: do range -->
                         (<xsl:value-of select="mb:begin"/>)</nobr><br/>
                      </xsl:when>
                      
                   </xsl:choose>
                </xsl:for-each>
                </td>
             </xsl:otherwise>
          </xsl:choose>
          <!-- Auto-gen -->
          <td>
          <!-- Are we a live work? -->
          <xsl:for-each select="mb:relation-list/mb:relation[@type-id='a3005666-a872-32c3-ad06-98af558e99b0'][1]">           
                  <xsl:for-each select="mb:attribute-list/mb:attribute">
                     <xsl:if test="@type-id='70007db6-a8bc-46d7-a770-80e6a0bb551a'">
                        live,
                     </xsl:if>
                  </xsl:for-each>
          </xsl:for-each>
          <!-- date of work? (select the first only) -->
          <xsl:for-each select="mb:relation-list/mb:relation[@type-id='a3005666-a872-32c3-ad06-98af558e99b0'][1]">           
             <xsl:choose>
                <xsl:when test="not(mb:begin)">
                   :
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="mb:begin"/>:
                </xsl:otherwise>
             </xsl:choose>
          </xsl:for-each>
          <!-- Where? event, place, or area (just pick the first found) -->
          <xsl:choose>
             <xsl:when test="mb:relation-list/mb:relation[@type-id='b06e6732-2603-47d3-8a49-9f589b430483']/mb:event/mb:name">
                <xsl:value-of select="mb:relation-list/mb:relation[@type-id='b06e6732-2603-47d3-8a49-9f589b430483']/mb:event/mb:name"/>
             </xsl:when>
             <xsl:otherwise>
                <xsl:choose>
                   <xsl:when test="mb:relation-list/mb:relation[@type-id='ad462279-14b0-4180-9b58-571d0eef7c51']/mb:place/mb:name">
                      <xsl:value-of select="mb:relation-list/mb:relation[@type-id='ad462279-14b0-4180-9b58-571d0eef7c51']/mb:place/mb:name"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:choose>
                         <xsl:when test="mb:relation-list/mb:relation[@type-id='37ef3a0c-cac3-4172-b09b-4ca98d2857fc']/mb:area/mb:name">
                            <xsl:value-of select="mb:relation-list/mb:relation[@type-id='37ef3a0c-cac3-4172-b09b-4ca98d2857fc']/mb:area/mb:name"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <!--[no performance info]-->
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:otherwise>
          </xsl:choose>
          </td>
          <!-- Disambig -->
          <td><xsl:value-of select="mb:disambiguation"/></td>
        </tr>
      </xsl:for-each>    
    </table>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

