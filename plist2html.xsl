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
        <script src="../static/vendor/jquery/jquery-3.1.1.min.js">&#160;</script>
        <script src="../static/vendor/vis/vis.min.js">&#160;</script>
         <link href="../static/vendor/vis/vis.min.css" rel="stylesheet" type="text/css" />
      </head>
      <body>
        <div id="main">
          <h1>UI Test Report</h1>
          <h2>Failures</h2>
          <div>
            <div id="failures" class="table">
              <xsl:apply-templates select="//array[preceding-sibling::*[1][text()='FailureSummaries']]" />
            </div>
          </div>
          <h2>Timeline</h2>
          <div id="timeline">
            <div id="visualization">
            </div>
          </div>
          <h2>Summary</h2>
          <div>
            <table id="table" class="table">
              <xsl:for-each select="//array[preceding-sibling::key[1][text()='ActivitySummaries']]">
                <tbody id="a{position()}">
                  <xsl:variable name="uuid" select="../string[preceding-sibling::*[text()='TestSummaryGUID']]" />
                  <tr>
                    <td>Test Name</td>
                    <td id="{$uuid}"><xsl:value-of select="../key[text() = 'TestName']/following-sibling::*" /></td>
                  </tr>
                  <tr>
                    <td>Test Status</td>
                    <td><xsl:value-of select="../key[text() = 'TestStatus']/following-sibling::*" /></td>
                  </tr>

                  <xsl:call-template name="activity" />
                </tbody>
              </xsl:for-each>
            </table>
          </div>
        </div>
        <script>
          <xsl:text disable-output-escaping="yes">
            <![CDATA[
              $(document).ready(function() {
              var container = document.getElementById('visualization');

              var items = [];
              var min = new Date(8640000000000000);
              var max = new Date(-8640000000000000);

              $('tbody time').each(function(n) {
                var d = new Date($(this).attr('datetime'));
                if (d < min) {
                  min = d;
                } else if (d > max) {
                  max = d;
                }

                items[n] = {id: 't' + n, content: $(this).parent().next().first().text(), start: d, group: $(this).closest('tbody').attr('id')}
              });

              max = new Date(max.getTime() + 5000);
              min = new Date(min.getTime() - 5000);

              var options = { max: max, min: min, moveable: false, zoomable: false, snap: null, timeAxis: {scale: 'millisecond', step: 100}, showMinorLabels: false, showMajorLabels: false, showCurrentTime: false, align: 'left'};
              var timeline = new vis.Timeline(container, new vis.DataSet(items), options);
              })
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

  <!-- Failures -->
  <xsl:template match="//array[preceding-sibling::*[1][text()='FailureSummaries']]/dict">
    <xsl:variable name="uuid" select="../../string[preceding-sibling::*[1][text()='TestSummaryGUID']]" />
    <xsl:for-each select=".">
      <div>
        <p><xsl:value-of select="*[preceding-sibling::*[1][text()='FileName']]" />::<xsl:value-of select="*[preceding-sibling::*[1][text()='LineNumber']]" /></p>
      </div>
      <div>
        <p><a href="#{$uuid}"><xsl:value-of select="*[preceding-sibling::*[1][text()='Message']]" /></a></p>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="activity">
    <xsl:for-each select="//dict">
      <xsl:if test="key[text()='Title']">
        <tr>
          <td>
            <xsl:variable name="ts" select="date:add('2001-01-01T00:00:00Z', date:duration(real[preceding-sibling::*[1][text()='StartTimeInterval']]))" />
            <time datetime="{$ts}">
              <xsl:value-of select="date:day-in-month($ts)" />&#160;
              <xsl:value-of select="date:month-abbreviation($ts) " />&#160;
              <xsl:value-of select="date:year($ts) " />&#160;
              <xsl:value-of select="substring(date:time($ts), 1, 12)" /> &#160;
            </time>
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
