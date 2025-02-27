<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  xmlns:str="http://exslt.org/strings"
  xmlns:exslt="http://exslt.org/common"
  extension-element-prefixes="str exslt xsl"
  exclude-result-prefixes="str exslt xsl">

<xsl:import href="xsl/str.tokenize.function.xsl"/>
<xsl:import href="xsl/lang.highlight.c.xsl"/>
<xsl:import href="xsl/lang.highlight.ebuild.xsl"/>
<xsl:import href="xsl/lang.highlight.make.xsl"/>
<xsl:import href="xsl/lang.highlight.m4.xsl"/>
<xsl:import href="xsl/lang.highlight.sgml.xsl"/>

<xsl:output method="html" version="5" encoding="UTF-8" doctype-system="about:legacy-compat"/>

<!-- When true, disable external assets for offline browsing.
     The parameter can be passed with "xsltproc -\-param offline 1". -->
<xsl:param name="offline" select="0"/>

<xsl:variable name="newline">
<xsl:text>
</xsl:text>
</xsl:variable>

<xsl:template match="chapter">
  <h1 class="first-header">
    <xsl:apply-templates select="title"/>
    <a class="permalink" href=""><span class="fa fa-link"/></a>
  </h1>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="section|subsection|subsubsection">
  <xsl:variable name="level" select="2 + number(starts-with(local-name(), 'sub'))
                                       + number(starts-with(local-name(), 'subsub'))"/>
  <xsl:variable name="anchor">
    <xsl:call-template name="convert-to-anchor">
      <xsl:with-param name="data" select="title"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="section">
    <xsl:element name="h{$level}">
      <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
      <xsl:apply-templates select="title"/>
      <a class="permalink" href="#{$anchor}"><span class="fa fa-link"/></a>
    </xsl:element>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </div>
</xsl:template>

<xsl:template match="body">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="p">
  <p>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="pre">
  <pre><xsl:apply-templates/></pre>
</xsl:template>

<!-- Tables -->
<!-- From the Gentoo GuideXML Stylesheet -->
<xsl:template match="table">
  <table class="table"><xsl:apply-templates/></table>
</xsl:template>

<xsl:template match="tr">
  <tr><xsl:apply-templates/></tr>
</xsl:template>

<!-- Table Item -->
<xsl:template match="ti">
  <td>
    <xsl:if test="@colspan">
      <xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@rowspan">
      <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@nowrap or @align">
      <xsl:attribute name="style">
        <!-- Disable word wrapping for this table item. Usage: <ti nowrap="nowrap"> -->
        <xsl:if test="@nowrap">white-space:<xsl:value-of select="@nowrap"/>;</xsl:if>
        <xsl:if test="@align">text-align:<xsl:value-of select="@align"/>;</xsl:if>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </td>
</xsl:template>

<!-- Table Heading -->
<xsl:template match="th">
  <th>
    <xsl:if test="@colspan">
      <xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@rowspan">
      <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@align">
        <xsl:attribute name="style">text-align:<xsl:value-of select="@align"/>;</xsl:attribute>
      </xsl:when>
      <xsl:when test="@colspan">
        <!-- Center only when item spans several columns as
             centering all <th> might disrupt some pages.
        -->
        <xsl:attribute name="style">text-align:center;</xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
  </th>
</xsl:template>
<!-- End Table Jojo -->

<!-- FIXME: Handle lang=... -->
<xsl:template match="codesample">
  <xsl:variable name="ctype"><xsl:if test="@lang = 'ebuild'">Constant</xsl:if></xsl:variable>
  <xsl:variable name="numbering" select="@numbering"/>
  <xsl:variable name="lang" select="@lang"/>
  <pre><span class="{$ctype}">

    <xsl:for-each select="str:tokenize_plasmaroo(., $newline)">
      <xsl:choose>
        <xsl:when test=". = $newline">
          <xsl:if test="position() != 1"><xsl:value-of select='$newline'/></xsl:if>
          <xsl:if test="$numbering = 'lines' and position() != last()-1">
            <span style="float: left;"><xsl:number format="01"/>:<xsl:text> </xsl:text></span>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$lang = 'ebuild'">
              <xsl:call-template name="lang.highlight.ebuild.tokenate">
                <xsl:with-param name="data" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$lang = 'make'">
              <xsl:call-template name="lang.highlight.make.tokenate">
                <xsl:with-param name="data" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$lang = 'm4'">
              <xsl:call-template name="lang.highlight.m4.tokenate">
                <xsl:with-param name="data" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$lang = 'sgml'">
              <xsl:call-template name="lang.highlight.sgml.tokenate">
                <xsl:with-param name="data" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$lang = 'c'">
              <xsl:call-template name="lang.highlight.c.tokenate">
                <xsl:with-param name="data" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>Error: Unknown language type (<xsl:value-of select="$lang"/>)</xsl:message>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </span></pre>
</xsl:template>

<xsl:template match="figure">
  <div class="figure">
    <div class="image"><img alt="{@short}" src="{@link}"/></div>
    <xsl:if test="@caption">
      <p class="caption"><xsl:value-of select="@caption"/></p>
    </xsl:if>
  </div>
</xsl:template>

<!-- Lists -->
<xsl:template match="li">
  <li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="ol">
  <ol><xsl:apply-templates/></ol>
</xsl:template>

<xsl:template match="ul">
  <xsl:choose>
    <xsl:when test="@class='list-group'">
      <ul class="list-group fix-links">
        <xsl:for-each select="li">
          <li class="list-group-item">
            <xsl:apply-templates>
              <xsl:with-param name="class">list-group-item</xsl:with-param>
            </xsl:apply-templates>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:when>
    <xsl:otherwise>
      <ul><xsl:apply-templates/></ul>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Definition Lists -->
<xsl:template match="dl">
  <dl><xsl:apply-templates/></dl>
</xsl:template>

<xsl:template match="dt">
  <dt><xsl:apply-templates/></dt>
</xsl:template>

<xsl:template match="dd">
  <dd><xsl:apply-templates/></dd>
</xsl:template>

<xsl:template match="note">
  <div class="alert alert-info" role="alert">
    <strong>Note:</strong>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="important">
  <div class="alert alert-warning" role="alert">
    <strong>Important:</strong>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="warning">
  <div class="alert alert-danger" role="alert">
    <strong>Warning:</strong>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="todo">
  <div class="alert alert-info" role="alert">
    <strong>Todo:</strong>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="b">
  <b><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="d">
  <xsl:text>&#8212;</xsl:text>
</xsl:template>

<xsl:template match="e">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="c">
  <code class="docutils literal"><span class="pre"><xsl:apply-templates/></span></code>
</xsl:template>

<xsl:template name="convert-to-anchor">
  <xsl:param name="data"/>
  <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz-</xsl:variable>
  <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ<xsl:text> </xsl:text></xsl:variable>
  <xsl:variable name="lcdata" select="translate(normalize-space($data), $ucletters, $lcletters)"/>
  <!-- Delete anything but letters, digits, hyphen, dot, underscore -->
  <xsl:variable name="allowed">abcdefghijklmnopqrstuvwxyz0123456789-._</xsl:variable>
  <xsl:value-of select="translate($lcdata, translate($lcdata, $allowed, ''), '')"/>
</xsl:template>

<xsl:template match="uri">
  <xsl:param name="class" />
  <xsl:choose>
    <xsl:when test="starts-with(@link, '::')">
      <!-- Ideally we would work out how many levels to nest down to save
           a few bytes but going down to root level works just as well
           (and is faster). -->
      <xsl:variable name="relative_path_depth"
                    select="string-length(/guide/@self) - string-length(translate(/guide/@self, '/' , ''))"/>
      <xsl:variable name="relative_path_depth_recursion">
        <xsl:call-template name="str:repeatString">
          <xsl:with-param name="count" select="$relative_path_depth"/>
          <xsl:with-param name="append">../</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains(@link, '##')">
          <xsl:variable name="slash">
            <xsl:if test="substring(substring-before(@link, '##'),
                          string-length(substring-before(@link, '##'))) != '/'">/</xsl:if>
          </xsl:variable>
          <a class="{$class}"
             href="{concat($relative_path_depth_recursion, substring-after(substring-before(@link, '##'), '::'),
                   $slash, 'index.html#', substring-after(@link, '##'))}">
            <xsl:value-of select="."/>
          </a>
        </xsl:when>
        <xsl:when test="contains(@link, '#')">
          <xsl:variable name="anchor">
            <xsl:call-template name="convert-to-anchor">
              <xsl:with-param name="data" select="substring-after(@link, '#')"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="slash">
            <xsl:if test="substring(substring-before(@link, '#'),
                          string-length(substring-before(@link, '#'))) != '/'">/</xsl:if>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test=". != ''">
              <a class="{$class}"
                 href="{concat($relative_path_depth_recursion, substring-after(substring-before(@link, '#'), '::'),
                       $slash, 'index.html#', $anchor)}">
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a class="{$class}"
                 href="{concat($relative_path_depth_recursion, substring-after(substring-before(@link, '#'), '::'),
                       $slash, 'index.html#', $anchor)}">
                <xsl:value-of select="substring-after(@link, '#')"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="slash">
            <xsl:if test="substring(@link, string-length(@link)) != '/'">/</xsl:if>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test=". != ''">
              <a class="{$class}"
                 href="{concat($relative_path_depth_recursion, substring-after(@link, '::'), $slash, 'index.html')}">
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:when test="starts-with(@link, '::eclass-reference/')
                            and substring-after(@link, '::eclass-reference/') != ''">
              <!-- Eclass reference pages are generated with man2html,
                   so there isn't any text.xml that could be loaded.
                   Use the name of the eclass as link text. #442194 -->
              <a class="{$class}"
                 href="{concat($relative_path_depth_recursion, substring-after(@link, '::'), $slash, 'index.html')}">
                <xsl:value-of select="substring-before(concat(substring-after(@link, '::eclass-reference/'), $slash), '/')"/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a class="{$class}"
                 href="{concat($relative_path_depth_recursion, substring-after(@link, '::'), $slash, 'index.html')}">
                <xsl:value-of select="document(concat(/guide/@self, $relative_path_depth_recursion,
                                      substring-after(@link, '::'), '/text.xml'))/guide/chapter[1]/title"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@link">
      <a class="{$class}" href="{@link}"><xsl:value-of select="."/></a>
    </xsl:when>
    <xsl:when test="contains(., '://')">
      <a class="{$class}" href="{.}"><xsl:value-of select="."/></a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Error: No link target (<xsl:value-of select="."/>)</xsl:message>
      <a class="{$class}"><xsl:value-of select="."/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- TOC Tree -->
<xsl:template match="contentsTree" name="contentsTree">
  <xsl:param name="depth" select="0"/>
  <xsl:param name="maxdepth">
    <xsl:choose>
      <xsl:when test="@maxdepth"><xsl:value-of select="@maxdepth"/></xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="path">
    <xsl:choose>
      <xsl:when test="@root"><xsl:value-of select="@root"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="/guide/@self"/></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="path_rel">
    <xsl:if test="$depth = 0 and $path = '' and /guide/@self != ''">
      <xsl:call-template name="str:repeatString">
        <xsl:with-param name="count"
                        select="string-length(/guide/@self) - string-length(translate(/guide/@self, '/' , ''))"/>
        <xsl:with-param name="append">../</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:param>
  <xsl:param name="extraction" select="@extraction"/>
  <xsl:param name="extraction_counting"/>

  <xsl:variable name="doc_self" select="concat($path, 'text.xml')"/>
  <xsl:if test="count(document($doc_self)/guide/include) &gt; 0 and ($depth &lt; $maxdepth or $maxdepth = '0')">
    <xsl:choose>
      <xsl:when test="$extraction_counting = 1">
        <xsl:for-each select="document($doc_self)/guide/include">
          <count value="{count(document(concat($path, @href, 'text.xml'))//*[name()=$extraction])}"
                 path="{concat($path, @href)}">
            <xsl:call-template name="contentsTree">
              <xsl:with-param name="depth" select="$depth + 1"/>
              <xsl:with-param name="maxdepth" select="$maxdepth"/>
              <xsl:with-param name="path" select="concat($path, @href)"/>
              <xsl:with-param name="path_rel" select="concat($path_rel, @href)"/>
              <xsl:with-param name="extraction" select="$extraction"/>
              <xsl:with-param name="extraction_counting" select="1"/>
            </xsl:call-template>
          </count>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:for-each select="document($doc_self)/guide/include">
            <xsl:variable name="extraction_counter_node">
              <xsl:call-template name="contentsTree">
                <xsl:with-param name="depth" select="$depth + 1"/>
                <xsl:with-param name="maxdepth" select="$maxdepth"/>
                <xsl:with-param name="path" select="concat($path, @href)"/>
                <xsl:with-param name="path_rel" select="concat($path_rel, @href)"/>
                <xsl:with-param name="extraction" select="$extraction"/>
                <xsl:with-param name="extraction_counting" select="1"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="extraction_counter"
                          select="count(exslt:node-set($extraction_counter_node)//*[@value != 0])
                                  + count(document(concat($path, @href, 'text.xml'))//*[name()=$extraction])"/>
            <xsl:if test="string($extraction) = '' or $extraction_counter &gt; 0">
              <li>
                <a class="reference" href="{concat($path_rel, @href, 'index.html')}">
                  <xsl:value-of select="document(concat($path, @href, 'text.xml'))/guide/chapter[1]/title"/>
                </a>
                <xsl:if test="$extraction != ''">
                  <ul>
                    <xsl:for-each select="document(concat($path, @href, 'text.xml'))//*[name()=$extraction]">
                      <xsl:variable name="extraction_id" select="position()"/>
                      <li><xsl:apply-templates select="(//*[name()=$extraction])[position()=$extraction_id]"/></li>
                    </xsl:for-each>
                  </ul>
                </xsl:if>
                <xsl:call-template name="contentsTree">
                  <xsl:with-param name="depth" select="$depth + 1"/>
                  <xsl:with-param name="maxdepth" select="$maxdepth"/>
                  <xsl:with-param name="path" select="concat($path, @href)"/>
                  <xsl:with-param name="path_rel" select="concat($path_rel, @href)"/>
                  <xsl:with-param name="extraction" select="$extraction"/>
                </xsl:call-template>
              </li>
            </xsl:if>
          </xsl:for-each>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="/">
  <xsl:variable name="relative_path_depth"
                select="string-length(/guide/@self) - string-length(translate(/guide/@self, '/' , ''))"/>
  <xsl:variable name="relative_path_depth_recursion">
    <xsl:call-template name="str:repeatString">
      <xsl:with-param name="count" select="$relative_path_depth"/>
      <xsl:with-param name="append">../</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <html lang="en">
    <head>
      <title><xsl:value-of select="/guide/chapter[1]/title"/> &#x2013; Gentoo Development Guide</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta name="description" content="The Gentoo Devmanual is a technical manual which covers topics such as writing ebuilds and eclasses, and policies that developers should be abiding by." />
      <xsl:choose>
        <xsl:when test="$offline">
          <link rel="stylesheet" href="{$relative_path_depth_recursion}offline.css" type="text/css" />
        </xsl:when>
        <xsl:otherwise>
          <link href="https://assets.gentoo.org/tyrian/bootstrap.min.css" rel="stylesheet" media="screen" />
          <link href="https://assets.gentoo.org/tyrian/tyrian.min.css" rel="stylesheet" media="screen" />
        </xsl:otherwise>
      </xsl:choose>
      <link rel="stylesheet" href="{$relative_path_depth_recursion}devmanual.css" type="text/css" />
      <link rel="icon" href="https://www.gentoo.org/favicon.ico" type="image/x-icon" />
    </head>
    <body>
      <header>
        <xsl:choose>
          <xsl:when test="$offline">
            <nav class="offline">
              <ul>
                <li><xsl:call-template name="findPrevious"/></li>
                <li><xsl:call-template name="findNext"/></li>
              </ul>
            </nav>
          </xsl:when>
          <xsl:otherwise>
            <div class="site-title">
              <div class="container">
                <div class="row">
                  <div class="site-title-buttons">
                    <div class="btn-group btn-group-sm">
                      <a href="https://get.gentoo.org/" role="button" class="btn get-gentoo"><span class="fa fa-fw fa-download"></span> <strong> Get Gentoo!</strong></a>
                      <div class="btn-group btn-group-sm">
                        <a class="btn gentoo-org-sites dropdown-toggle" data-toggle="dropdown" data-target="#" href="#">
                          <span class="fa fa-fw fa-map-o"></span> <span class="hidden-xs"> gentoo.org sites </span> <span class="caret"></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-right">
                          <li><a href="https://www.gentoo.org/" title="Main Gentoo website"><span class="fa fa-home fa-fw"></span> gentoo.org</a></li>
                          <li><a href="https://wiki.gentoo.org/" title="Find and contribute documentation"><span class="fa fa-file-text-o fa-fw"></span> Wiki</a></li>
                          <li><a href="https://bugs.gentoo.org/" title="Report issues and find common issues"><span class="fa fa-bug fa-fw"></span> Bugs</a></li>
                          <li><a href="https://forums.gentoo.org/" title="Discuss with the community"><span class="fa fa-comments-o fa-fw"></span> Forums</a></li>
                          <li><a href="https://packages.gentoo.org/" title="Find software for your Gentoo"><span class="fa fa-hdd-o fa-fw"></span> Packages</a></li>
                          <li class="divider"></li>
                          <li><a href="https://planet.gentoo.org/" title="Find out what's going on in the developer community"><span class="fa fa-rss fa-fw"></span> Planet</a></li>
                          <li><a href="https://archives.gentoo.org/" title="Read up on past discussions"><span class="fa fa-archive fa-fw"></span> Archives</a></li>
                          <li><a href="https://sources.gentoo.org/" title="Browse our source code"><span class="fa fa-code fa-fw"></span> Sources</a></li>
                          <li class="divider"></li>
                          <li><a href="https://infra-status.gentoo.org/" title="Get updates on the services provided by Gentoo"><span class="fa fa-server fa-fw"></span> Infra Status</a></li>
                        </ul>
                      </div>
                    </div>
                  </div>
                  <div>
                    <a href="/" title="Back to the homepage" class="site-logo">
                      <object data="https://assets.gentoo.org/tyrian/site-logo.svg" type="image/svg+xml">
                        <img src="https://assets.gentoo.org/tyrian/site-logo.png" alt="Gentoo Linux Logo" />
                      </object>
                    </a>
                    <span class="site-label">Development Guide</span>
                  </div>
                </div>
              </div>
            </div>
            <nav class="tyrian-navbar" role="navigation">
              <div class="container">
                <div class="row">
                  <div class="navbar-header">
                    <button type="button" class="navbar-toggle"
                            data-toggle="collapse" data-target=".navbar-main-collapse">
                      <span class="sr-only">Toggle navigation</span>
                      <span class="icon-bar"></span>
                      <span class="icon-bar"></span>
                      <span class="icon-bar"></span>
                    </button>
                  </div>
                  <div class="collapse navbar-collapse navbar-main-collapse">
                    <ul class="nav navbar-nav">
                      <li>
                        <a href="{$relative_path_depth_recursion}index.html"><span class="fa fa-home"/>&#160;Home</a>
                      </li>
                      <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">Index&#160;<span class="caret"></span></a>
                        <xsl:if test="/guide/chapter[1]/section or //contentsTree">
                          <ul class="dropdown-menu">
                            <!-- List sections of this chapter first. -->
                            <xsl:for-each select="/guide/chapter[1]/section">
                              <xsl:variable name="anchor">
                                <xsl:call-template name="convert-to-anchor">
                                  <xsl:with-param name="data" select="title"/>
                                </xsl:call-template>
                              </xsl:variable>
                              <li><a class="reference" href="#{$anchor}"><xsl:value-of select="title"/></a></li>
                            </xsl:for-each>
                            <xsl:if test="//contentsTree">
                              <li class="divider"></li>
                              <!-- List any sub-documents included at first level.
                                   We cannot call "contentsTree" directly, because it would
                                   insert another "ul" element. So, assign it to a variable,
                                   then copy only the "li" nodes. -->
                              <xsl:variable name="contents">
                                <xsl:call-template name="contentsTree">
                                  <xsl:with-param name="maxdepth" select="1"/>
                                </xsl:call-template>
                              </xsl:variable>
                              <xsl:copy-of select="exslt:node-set($contents)/ul/li"/>
                            </xsl:if>
                          </ul>
                        </xsl:if>
                      </li>
                      <li><xsl:call-template name="findPrevious"/></li>
                      <li><xsl:call-template name="findNext"/></li>
                    </ul>
                  </div>
                </div>
              </div>
            </nav>
            <nav class="navbar navbar-grey navbar-stick" id="devmanual-actions" role="navigation">
              <div class="container">
                <div class="row">
                  <div class="input-group">
                    <input type="search" name="search" placeholder="Search" title="Search Gentoo Developer Manual [f]"
                           accesskey="f" id="searchInput" class="form-control" onclick="fetchDocuments()"/>
                    <div class="input-group-btn">
                      <input type="submit" name="fulltext" value="Search" title="Search the pages for this text"
                             id="mw-searchButton" class="searchButton btn btn-default" onclick="search()"/>
                    </div>
                  </div>
                </div>
              </div>
            </nav>
            <div id="searchResults" class="modal fade" role="dialog">
              <div class="modal-dialog">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">x</button>
                    <h4 class="modal-title">Search Results</h4>
                  </div>
                  <div class="modal-body">
                    <p>No results found.</p>
                  </div>
                  <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                  </div>
                </div>
              </div>
            </div>
          </xsl:otherwise>
        </xsl:choose>
        <div class="container">
          <div class="row">
            <div class="col-md010">
              <ol class="breadcrumb">
                <xsl:call-template name="printParentDocs"/>
              </ol>
            </div>
          </div>
        </div>
      </header>
      <main>
        <div class="container">
          <xsl:apply-templates/>
        </div>
      </main>
      <footer>
        <div class="container">
          <xsl:if test="not($offline)">
            <div class="row">
              <div class="col-xs-12 col-md-offset-2 col-md-7">
              </div>
              <div class="col-xs-12 col-md-3">
                <h3 class="footerhead">Questions or comments?</h3>
                Please feel free to <a href="https://www.gentoo.org/inside-gentoo/contact/">contact us</a>.
              </div>
            </div>
          </xsl:if>
          <div class="row">
            <div class="col-xs-2 col-sm-3 col-md-2">
              <xsl:if test="not($offline)">
                <ul class="footerlinks three-icons">
                  <li><a href="https://twitter.com/gentoo" title="@Gentoo on Twitter"><span class="fa fa-twitter fa-fw"></span></a></li>
                  <li><a href="https://www.facebook.com/gentoo.org" title="Gentoo on Facebook"><span class="fa fa-facebook fa-fw"></span></a></li>
                </ul>
              </xsl:if>
            </div>
            <div class="col-xs-10 col-sm-9 col-md-10">
              <strong>Copyright (C) 2001-2022 Gentoo Authors</strong><br />
              <small>
                Gentoo is a trademark of the Gentoo Foundation, Inc.
                The text of this document is distributed under the
                <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
                The <a href="https://www.gentoo.org/inside-gentoo/foundation/name-logo-guidelines.html">Gentoo Name and Logo Usage Guidelines</a> apply.
              </small>
            </div>
          </div>
        </div>
      </footer>
      <xsl:if test="not($offline)">
        <script src="https://assets.gentoo.org/tyrian/jquery.min.js"></script>
        <script src="https://assets.gentoo.org/tyrian/bootstrap.min.js"></script>
        <script src="https://assets.gentoo.org/lunr/lunr.min.js"></script>
        <script>var documentsSrc = "<xsl:value-of select="$relative_path_depth_recursion"/>documents.js"</script>
        <script src="{$relative_path_depth_recursion}search.js"></script>
      </xsl:if>
    </body>
  </html>
</xsl:template>

<xsl:template name="str:repeatString">
  <xsl:param name="string"/>
  <xsl:param name="count"/>
  <xsl:param name="append"/>
  <xsl:choose>
    <xsl:when test="$count != 0">
      <xsl:call-template name="str:repeatString">
        <xsl:with-param name="string" select="concat($string, $append)"/>
        <xsl:with-param name="count" select="$count - 1"/>
        <xsl:with-param name="append" select="$append"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="findNext">
  <xsl:param name="self" select="/guide/@self"/>
  <xsl:choose>
    <!-- To find the "next" node:
         * See if this node includes any subnodes... if it does, that is
           our next node
         * Look at our parent and see if it includes any nodes after us,
           if it does use it.
         * Repeat recursively, going down parents if needed.
         * End at the root item if needed.
    -->
    <xsl:when test="count(/guide/include) &gt; 0">
      <xsl:variable name="doc" select="/guide/include[1]/@href"/>
      <a class="w-250 text-center" href="{concat($doc, 'index.html')}">
        <span class="truncated-text d-inline-block max-w-200 mr-2">
          <xsl:value-of select="document(concat(/guide/@self, $doc, 'text.xml'))/guide/chapter[1]/title"/>
        </span>
        <span class="fa fa-arrow-right"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <!-- Turn the absolute path into a relative path so we can find ourselves
           in the parent -->
      <xsl:variable name="path_self" select="concat(str:tokenize($self, '/')[last()], '/')"/>
      <xsl:variable name="index_self"
                    select="count(document(concat($self, '../text.xml'))/guide/include[@href=$path_self]/preceding-sibling::*)+1"/>
      <!-- Go down a parent, lookup the item after us... -->
      <xsl:variable name="parentItem_lookup"
                    select="document(concat($self, '../text.xml'))/guide/include[$index_self]/@href"/>
      <xsl:variable name="parentItem_next"
                    select="concat(document(concat($self, '../text.xml'))/guide/@self, $parentItem_lookup)"/>
      <xsl:choose>
        <!-- If we have an item after us, or we are at the root node
             (termination condition) we need to not recurse any further... -->
        <xsl:when test="$parentItem_lookup != '' or document(concat($self, '../text.xml'))/guide/@root">
          <xsl:variable name="parentItem_actual">
            <xsl:choose>
              <xsl:when test="$parentItem_next = ''"></xsl:when>
              <xsl:otherwise><xsl:value-of select="$parentItem_next"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- This is where we do a little trickery. To count how many levels
               we need to go down, we count how far up we currently are
               (remember that the absolute link we get is relative to /...)
               and hence we can build a relative link... -->
          <xsl:variable name="relative_path" select="$parentItem_actual"/>
          <xsl:variable name="relative_path_depth"
                        select="string-length(/guide/@self) - string-length(translate(/guide/@self, '/' , ''))"/>
          <xsl:variable name="relative_path_depth_recursion">
            <xsl:call-template name="str:repeatString">
              <xsl:with-param name="count" select="$relative_path_depth"/>
              <xsl:with-param name="append">../</xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <a class="w-250 text-center" href="{concat($relative_path_depth_recursion, $relative_path, 'index.html')}">
            <span class="truncated-text d-inline-block max-w-200 mr-2">
              <xsl:value-of select="document(concat($parentItem_actual, 'text.xml'))/guide/chapter[1]/title"/>
            </span>
            <span class="fa fa-arrow-right"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <!-- We need to recurse downwards; so we need to strip off a directory
               element off our absolute path to feed into the next iteration... -->
          <xsl:variable name="relative_path_depth"
                        select="string-length($self) - string-length(translate($self, '/' , ''))"/>
          <xsl:variable name="relative_path_fixed">
            <xsl:for-each select="str:tokenize_plasmaroo($self, '/')[position() &lt; (($relative_path_depth - 1)*2 + 1)]">
              <xsl:value-of select="."/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:call-template name="findNext">
            <xsl:with-param name="self" select="$relative_path_fixed"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="getLastNode">
  <!-- This function recurses forward down nodes stopping at the very last include... -->
  <xsl:param name="root"/>
  <xsl:param name="path"/>
  <xsl:variable name="include" select="document(concat($root, $path))/guide/include[last()]/@href"/>
  <xsl:choose>
    <xsl:when test="$include">
      <xsl:call-template name="getLastNode">
        <xsl:with-param name="root" select="$root"/>
        <xsl:with-param name="path" select="concat(substring-before($path, 'text.xml'), $include, 'text.xml')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$path"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="findPrevious">
  <xsl:choose>
    <!-- To find the "previous" node:
         * Go down to our parent
           * See if there are any nodes before us
             * If we have a valid node that is before us
             * Fully recurse up the node to get the last extremity
           * Otherwise list the parent -->
    <xsl:when test="/guide/@root">
      <a class="w-250 text-center" href="#">
        <span class="fa fa-arrow-left"/>
        <span class="truncated-text d-inline-block max-w-200 ml-2">
          <xsl:value-of select="/guide/chapter[1]/title"/>
        </span>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <!-- Turn the absolute path we have into a relative path so we can find
           ourselves in the parent -->
      <xsl:variable name="path_self" select="concat(str:tokenize(/guide/@self, '/')[last()], '/')"/>
      <xsl:variable name="index_self" select="count(document(concat(/guide/@self, '../text.xml'))/guide/include[@href=$path_self]/preceding-sibling::*)-1"/>
      <xsl:choose>
        <xsl:when test="$index_self &gt; 0">
          <!-- Relative path of the parent -->
          <xsl:variable name="parentItem_path" select="document(concat(/guide/@self, '../text.xml'))/guide/@self"/>
          <!-- Previous item in the parent -->
          <xsl:variable name="parentItem_next"
                        select="document(concat(/guide/@self, '../text.xml'))/guide/include[$index_self]/@href"/>
          <xsl:variable name="myItem_path">
            <xsl:call-template name="getLastNode">
              <xsl:with-param name="root" select="$parentItem_path"/>
              <xsl:with-param name="path" select="concat($parentItem_next, 'text.xml')"/>
            </xsl:call-template>
          </xsl:variable>
          <!-- Make a relative <a> link; we need an absolute reference
               for the XSLT processor though... -->
          <a class="w-250 text-center" href="{concat('../', substring-before($myItem_path, 'text.xml'), 'index.html')}">
            <span class="fa fa-arrow-left"/>
            <span class="truncated-text d-inline-block max-w-200 ml-2">
              <xsl:value-of select="document(concat($parentItem_path, $myItem_path))/guide/chapter[1]/title"/>
            </span>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <a class="w-250 text-center" href="../index.html">
            <span class="fa fa-arrow-left"/>
            <span class="truncated-text d-inline-block max-w-200 ml-2">
              <xsl:value-of select="document(concat(/guide/@self, '../text.xml'))/guide/chapter[1]/title"/>
            </span>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="printParentDocs">
  <xsl:param name="depth" select="string-length(/guide/@self) - string-length(translate(/guide/@self, '/', ''))"/>
  <xsl:choose>
    <xsl:when test="$depth &gt; 0">
      <xsl:variable name="relative_path_depth_recursion">
        <xsl:call-template name="str:repeatString">
          <xsl:with-param name="count" select="$depth"/>
          <xsl:with-param name="append">../</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <li>
        <a href="{$relative_path_depth_recursion}index.html">
          <xsl:value-of select="document(concat(/guide/@self, $relative_path_depth_recursion, 'text.xml'))/guide/chapter[1]/title"/>
        </a>
      </li>
      <xsl:call-template name="printParentDocs">
        <xsl:with-param name="depth" select="$depth - 1"/>
      </xsl:call-template>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="author">
  <dt>
    <xsl:value-of select="@name"/>
    <xsl:if test="@email != ''"> &lt;<a href="mailto:{@email}"><xsl:value-of select="@email"/></a>&gt;</xsl:if>
  </dt>
  <dd><xsl:apply-templates/></dd>
</xsl:template>

<xsl:template match="authorlist">
  <dt><xsl:value-of select="@title"/></dt>
  <dd>
    <xsl:for-each select="document(concat(@href, 'text.xml'))//author">
      <xsl:value-of select="@name"/>
      <xsl:if test="position() != last()">, </xsl:if>
    </xsl:for-each>
  </dd>
</xsl:template>

<xsl:template match="authors">
  <dl>
    <xsl:apply-templates/>
  </dl>
</xsl:template>

</xsl:stylesheet>

<!-- Local Variables: -->
<!-- indent-tabs-mode: nil -->
<!-- fill-column: 120 -->
<!-- End: -->
