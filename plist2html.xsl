<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="date">
  <xsl:output method="html"/>
  <xsl:param name="attachments" />

  <xsl:template match="/">
    <html>
      <head>
        <title>Xcode UI Testing report</title>
        <link rel="stylesheet" href="../static/table.css" />
        <script src="../static/jquery-3.1.1.min.js">&#160;</script>
      </head>
      <body>
        <div id="main">
          <h1>UI Test Report</h1>
          <div>
            <table id="table" class="table">
              <tbody>
                <xsl:for-each select="//array[preceding-sibling::key[1][text()='ActivitySummaries']]">
                  <xsl:call-template name="activity" />
                </xsl:for-each>
              </tbody>
            </table>
          </div>
        </div>
        <script>
          <xsl:text disable-output-escaping="yes">
            <![CDATA[
            ]]>
          </xsl:text>
        </script>
      </body>
    </html>
  </xsl:template>

  <!-- Booleans -->
  <xsl:template match="false">
    <span class="false">false</span>
  </xsl:template>
  <xsl:template match="true">
    <span class="true">true</span>
  </xsl:template>

  <xsl:template name="activity">
    <xsl:for-each select="//dict">
      <xsl:if test="key[text()='Title']">
        <tr>
          <td>
            <xsl:variable name="ts" select="real[preceding-sibling::*[1][text()='StartTimeInterval']]" />
            <xsl:value-of select="date:add('2001-01-01T00:00:00Z', date:duration($ts))" />
          </td>
          <td><xsl:value-of select="string[preceding-sibling::*[1][text()='Title']]" /></td>
        </tr>


        <xsl:if test="true[preceding-sibling::key[1][text()='HasScreenshotData']]">
          <xsl:variable name="uuid" select="string[preceding-sibling::key[1][text()='UUID']]" />
          <tr>
            <td>Screen Capture</td>
            <td><img src="{$attachments}/Screenshot_{$uuid}.png" /></td>
          </tr>
        </xsl:if>

      </xsl:if>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
