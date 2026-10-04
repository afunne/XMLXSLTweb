<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

	<!-- Parameetrid (antakse HomeController.Isoleveta meetodist) -->
	<xsl:param name="aasta">2026</xsl:param>
	<xsl:param name="otsing">li</xsl:param>
	<xsl:param name="pikkus" select="6"/>

	<xsl:template match="/">
		<h2>Sugupuu</h2>
		<ul class="sugupuu">
			<xsl:apply-templates select="inimene"/>
		</ul>

		<h2>Näita kõik nimed, mis algavad tähega "C"</h2>
		<ul>
			<xsl:for-each select="//inimene[starts-with(nimi, 'C')]">
				<li>
					<xsl:value-of select="nimi"/>
				</li>
			</xsl:for-each>
			<xsl:if test="not(//inimene[starts-with(nimi, 'C')])">
				<li>ei leitud</li>
			</xsl:if>
		</ul>

		<h2>Parameetrite kasutamine</h2>
		<p>
			Otsitakse kõiki nimesid, mis sisaldavad tähemärki
			<strong>
				<xsl:value-of select="$otsing"/>
			</strong>
		</p>
		<ul>
			<xsl:for-each select="//inimene[contains(nimi, $otsing)]">
				<li>
					<xsl:value-of select="nimi"/>
				</li>
			</xsl:for-each>
			<xsl:if test="not(//inimene[contains(nimi, $otsing)])">
				<li>ei leitud</li>
			</xsl:if>
		</ul>
		<p>
			Otsitakse kõiki nimesid, mis on pikemad kui
			<strong>
				<xsl:value-of select="$pikkus"/>
			</strong>
			tähemärki
		</p>
		<ul>
			<xsl:for-each select="//inimene[string-length(nimi) &gt; $pikkus]">
				<li>
					<xsl:value-of select="concat(nimi, ' (', string-length(nimi), ' tähemärki)')"/>
				</li>
			</xsl:for-each>
			<xsl:if test="not(//inimene[string-length(nimi) &gt; $pikkus])">
				<li>ei leitud</li>
			</xsl:if>
		</ul>

		<h2>Kasutame if-lauset: iga inimese kohta näitame, mitmendal oma vanema sünnipäeval ta sündis</h2>
		<ul>
			<xsl:for-each select="//inimene">
				<li>
					<xsl:value-of select="nimi"/>
					<xsl:if test="../../@synd">
						<xsl:text> - vanema vanus oli </xsl:text>
						<xsl:value-of select="@synd - ../../@synd"/>
					</xsl:if>
				</li>
			</xsl:for-each>
		</ul>

		<h2>Värvime nimed pikkusega rohkem kui 7</h2>
		<table class="table table-striped">
			<thead>
				<tr>
					<th>Nimi</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="//inimene">
					<tr>
						<td>
							<xsl:if test="string-length(nimi) &gt; 7">
								<xsl:attribute name="style">color: red; font-weight: bold;</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="nimi"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>

		<h2>Tabel</h2>
		<table class="table table-striped">
			<thead>
				<tr>
					<th>Nimi</th>
					<th>Aasta</th>
					<th>Vanus</th>
					<th>1. täht</th>
					<th>Viimane täht</th>
					<th>Tähtede arv</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="//inimene">
					<tr>
						<td>
							<xsl:value-of select="nimi"/>
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="@synd">
									<xsl:value-of select="@synd"/>
								</xsl:when>
								<xsl:otherwise>-</xsl:otherwise>
							</xsl:choose>
						</td>
						<td>
							<xsl:call-template name="vanus"/>
						</td>
						<td>
							<xsl:value-of select="substring(nimi, 1, 1)"/>
						</td>
						<td>
							<xsl:value-of select="substring(nimi, string-length(nimi), 1)"/>
						</td>
						<td>
							<!-- tühikuid ei loeta -->
							<xsl:value-of select="string-length(translate(nimi, ' ', ''))"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- Rekursiivne mall: inimene ja tema lapsed (lastega inimese nimi on punane) -->
	<xsl:template match="inimene">
		<li>
			<span>
				<xsl:if test="lapsed/inimene">
					<xsl:attribute name="style">color: red; font-weight: bold;</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="nimi"/>
			</span>
			<xsl:if test="@synd">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@synd"/>
				<xsl:if test="@surm">
					<xsl:value-of select="concat('-', @surm)"/>
				</xsl:if>
				<xsl:text>, vanus </xsl:text>
				<xsl:call-template name="vanus"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:if test="lapsed/inimene">
				<ul>
					<xsl:apply-templates select="lapsed/inimene"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>

	<!-- Vanus: elav inimene -> aasta - synd, surnud -> "oli" surm - synd, sünniaastat pole -> "-" -->
	<xsl:template name="vanus">
		<xsl:choose>
			<xsl:when test="not(@synd)">-</xsl:when>
			<xsl:when test="@surm">
				<xsl:value-of select="concat('oli ', @surm - @synd)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$aasta - @synd"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
