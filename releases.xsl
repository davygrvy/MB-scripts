<?xml version="1.0"?>
<!--

Call this from the commandline something like this:
wget -O - https://musicbrainz.org/ws/2/release?artist=678d88b2-87b0-403b-b63d-5da7465aecc3\&status=bootleg\&type=live\&inc=release-groups+place-rels+event-rels+area-rels\&limit=25\&offset=0 |xsltproc -o releases.html releases.xsl -; google-chrome releases.html

See https://musicbrainz.org/doc/MusicBrainz_API for details

-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:mb="http://musicbrainz.org/ns/mmd-2.0#">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <html>
    <body>
    <h2>MusicBrainz release decoder test by davygrvy@pobox.com</h2>
    Count is <xsl:value-of select="mb:metadata/mb:release-list/@count" /><br/>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>Title</th>
        <th>Status</th>
        <th>Attributes</th>
        <th>Performance</th>
        <th>Disambig</th>
      </tr>
      <xsl:for-each select="mb:metadata/mb:release-list/mb:release">
        <tr>
          <!-- Title -->
          <td><a href="https://musicbrainz.org/release/{@id}"><xsl:value-of select="mb:title"/></a></td>
          <!-- Status -->
          <td><xsl:value-of select="mb:status"/></td>
          <!-- Attributes -->
          <td>
          <xsl:choose>
             <xsl:when test="not(mb:release-group/mb:secondary-type-list/mb:secondary-type)">
                <nobr><xsl:value-of select="mb:release-group/mb:primary-type"/></nobr>
             </xsl:when>
             <xsl:otherwise>
                <nobr><xsl:value-of select="mb:release-group/mb:primary-type"/> + </nobr>
                <!-- XSLT 2.0 only <xsl:value-of select="mb:release-group/mb:secondary-type-list/mb:secondary-type" separator=" + "/> -->
                <xsl:for-each select="mb:release-group/mb:secondary-type-list/mb:secondary-type">
                   <nobr><xsl:value-of select="."/>
                   <xsl:if test="position() != last()">
                      <xsl:text> + </xsl:text> <!-- Add the separator if it's not the last item -->
                   </xsl:if>
                   </nobr>
                </xsl:for-each>
             </xsl:otherwise>
          </xsl:choose>
          </td>
          <!-- Performance -->
          <xsl:choose>
             <!-- Any 'recorded at/in' attributes? -->
             <xsl:when test="not(mb:relation-list/mb:relation
                              [
                                @type-id='4dda6e40-14af-46bb-bb78-ea22f4a99dfa' or
                                @type-id='3b1fae9f-5b22-42c5-a40c-d1e5c9b90251' or
                                @type-id='354043e1-bdc2-4c7f-b338-2bf9c1d56e88'
                              ])">
                <td>[no data]</td>
             </xsl:when>
             <xsl:otherwise>
                <td>
                <xsl:for-each select="mb:relation-list/mb:relation">           
                   <xsl:choose>
                      <xsl:when test="@type-id='4dda6e40-14af-46bb-bb78-ea22f4a99dfa'">
                         <!-- 'recorded at' for event, but we can't see 'held in/at', so display name with link to event -->
                         
                         <nobr><a href="https://musicbrainz.org/event/{mb:event/@id}"><xsl:value-of select="mb:event/mb:name"/></a>
                         <!-- TODO: do range instead of just begin -->
                         (<xsl:value-of select="mb:event/mb:life-span/mb:begin"/>)</nobr><br/>
                      </xsl:when>
                      
                      <xsl:when test="@type-id='3b1fae9f-5b22-42c5-a40c-d1e5c9b90251'">
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
                         (<xsl:value-of select="mb:begin"/>)</nobr><br/>
                      </xsl:when>
                      
                      <xsl:when test="@type-id='354043e1-bdc2-4c7f-b338-2bf9c1d56e88'">
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
                         (<xsl:value-of select="mb:begin"/>)</nobr><br/>
                      </xsl:when>
                      
                   </xsl:choose>
                </xsl:for-each>
                </td>
             </xsl:otherwise>
          </xsl:choose>
          <!-- Disambig -->
          <td><xsl:value-of select="mb:disambiguation"/></td>
        </tr>
      </xsl:for-each>    
    </table>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

