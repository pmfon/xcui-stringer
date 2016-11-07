<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>Xcode UI Testing report</title>
        <link rel="stylesheet" href="../static/jquery.treegrid.css" />
        <link rel="stylesheet" href="../static/table.css" />
        <script src="../static/jquery-3.1.1.min.js">&#160;</script>
        <script src="../static/jquery.treegrid.min.js">&#160;</script>

        <style>
          .treegrid-indent {width:16px; height: 16px; display: inline-block; position: relative;}
          .treegrid-expander {width:16px; height: 16px; display: inline-block; position: relative; cursor: pointer;}
          .treegrid-expander-expanded{background-image: url(../static/collapse.png); }
          .treegrid-expander-collapsed{background-image: url(../static/expand.png); }
        </style>
      </head>
      <body>
        <div id="main">
          <h1>UI Test Report</h1>

          <div>
            <table id="table" class="tree table">
              <tbody>
                <tr class="treegrid-1 treegrid-expanded"><td colspan="2">&#160;</td></tr>
                <xsl:apply-templates>
                  <xsl:with-param name="pid" select="treegrid-1" />
                </xsl:apply-templates>
              </tbody>
            </table>
          </div>
        </div>
        <script>
          <xsl:text disable-output-escaping="yes">
            <![CDATA[
            function linkImages() {

            $('td').each(function(){
            var td = $(this);
            td.html(
            td.text().replace(
            /[A-Z0-9-]{30,39}/g,
            '<a href="../media/Screenshot_$&.png">$&</a>'
            )
            )
            });
            }

            $(document).ready(function() {
            linkImages();
            $('.tree').treegrid();
            });
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

  <!-- Handle nested dictionaries -->
  <xsl:template name="defaultHandler">
    <xsl:param name="pid" />

    <xsl:apply-templates select="following-sibling::*[1]">
      <xsl:with-param name="pid" select="$pid" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="valOrDict">
    <xsl:param name="pid" />
    <xsl:param name="nid" />

    <xsl:choose>
      <xsl:when test="following-sibling::*[1][dict]">
        <tr data-tt-id="{$nid}" data-tt-parent-id="{$pid}" class="treegrid-{$nid} treegrid-parent-{$pid}">
          <td colspan="2"><xsl:value-of select="." /></td>
        </tr>
        <xsl:call-template name="defaultHandler">
          <xsl:with-param name="pid" select="$nid" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="following-sibling::*[1][array]">
        <xsl:call-template name="defaultHandler">
          <xsl:with-param name="pid" select="$nid" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <tr data-tt-id="{$nid}" data-tt-parent-id="{$pid}"
          class="treegrid-{$nid} treegrid-parent-{$pid}">
          <td><xsl:value-of select="." /></td>
          <td>
            <xsl:call-template name="defaultHandler">
              <xsl:with-param name="pid" select="$pid" />
            </xsl:call-template>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="//array">
    <xsl:param name="pid" />
    <xsl:variable name="nid" select="concat(name(), count(ancestor::*))" />

    <tr data-tt-id="{$nid}" data-tt-parent-id="{$pid}" class="treegrid-{$nid} treegrid-parent-{$pid}" />
    <xsl:for-each select="*">
      <xsl:apply-templates select=".">
        <xsl:with-param name="pid" select="$nid" />
      </xsl:apply-templates>
    </xsl:for-each>

  </xsl:template>

  <!-- Handle the root plists -->
  <xsl:template match="//dict[not(../plist)]">
    <xsl:param name="pid" />
    <xsl:for-each select="key">
      <xsl:variable name="nid" select="concat(text(), count(ancestor::*))" />
      <xsl:call-template name="valOrDict">
        <xsl:with-param name="pid" select="$pid" />
        <xsl:with-param name="nid" select="$nid" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
