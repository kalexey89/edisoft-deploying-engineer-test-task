<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	
	<xsl:param name="doc_fn_code">9</xsl:param> <!-- Document function code /-->
	<xsl:param name="doc_name_code">351</xsl:param> <!-- Document name code /-->
	<xsl:param name="deliveries_num">1</xsl:param> <!-- Number of deliveries /-->
	
	<xsl:template match="/">
		<Document-DespatchAdvice>
			<DispatchAdvice-Header>
				<xsl:apply-templates select="//Document-Header" />
			</DispatchAdvice-Header>
			<Document-Parties>
				<Sender>
					<ILN>
						<xsl:value-of select="normalize-space(//Фирма/@GLN)" />
					</ILN>
				</Sender>
				<Receiver>
					<ILN>
						<xsl:value-of select="normalize-space(//Клиент/@GLN)" />
					</ILN>
				</Receiver>
			</Document-Parties>
			<DespatchAdvice-Parties>
				<Buyer>
					<ILN>
						<xsl:value-of select="normalize-space(//Клиент/@GLN)" />
					</ILN>
				</Buyer>
				<Seller>
					<ILN>
						<xsl:value-of select="normalize-space(//Фирма/@GLN)" />
					</ILN>
				</Seller>
				<DeliveryPoint>
					<ILN>
						<xsl:value-of select="normalize-space(//АдрДоставки/@GLN)" />
					</ILN>
				</DeliveryPoint>
			</DespatchAdvice-Parties>
			<DespatchAdvice-Consignment>
				<xsl:apply-templates select="//Document-Line" />
			</DespatchAdvice-Consignment>
		</Document-DespatchAdvice>
		<DespatchAdvice-Summary>
			<TotalPSequence>
				<xsl:value-of select="$deliveries_num" />
			</TotalPSequence>
			<TotalLines>
				<xsl:value-of select="count(//Line-Item)" />
			</TotalLines>
			<TotalGoodsDespatchedAmount>
				<xsl:value-of select="sum(//Количество)" />
			</TotalGoodsDespatchedAmount>
		</DespatchAdvice-Summary>
	</xsl:template>
	
	<xsl:template match="Document-Header">
		<DespatchAdviceNumber>
			<xsl:value-of select="//НомерДок" />
		</DespatchAdviceNumber>
		<DespatchAdviceDate>
			<xsl:call-template name="convert-date">
				<xsl:with-param name="date" select="//ДатаДок" />
			</xsl:call-template>
		</DespatchAdviceDate>
		<EstimatedDeliveryDate>
			<xsl:call-template name="convert-date">
				<xsl:with-param name="date" select="//ДатаПоставки" />
			</xsl:call-template>
		</EstimatedDeliveryDate>
		<BuyerOrderNumber>
			<xsl:value-of select="substring-before(//Основание, ' ')" />
		</BuyerOrderNumber>
		<DocumentFunctionCode>
			<xsl:value-of select="$doc_fn_code" />
		</DocumentFunctionCode>
		<DocumentNameCode>
			<xsl:value-of select="$doc_name_code" />
		</DocumentNameCode>
	</xsl:template>
	
	<xsl:template match="Document-Line">
		<Packing-Sequence>
			<xsl:apply-templates select="Line-Item" />
		</Packing-Sequence>
	</xsl:template>
	
	<xsl:template match="Line-Item|*">
	
		<xsl:variable name="price_with_vat" select="format-number(((Цена * СтавкаНДС) div 100) + Цена, '#.##')" />
		<xsl:variable name="sum_without_vat" select="format-number(Цена * Количество, '#.##')" />
		<xsl:variable name="vat_sum" select="format-number(((Цена * СтавкаНДС) div 100) * Количество, '#.##')" />
		<xsl:variable name="sum_with_vat" select="format-number($sum_without_vat + $vat_sum, '#.##')" />
				
		<Line>
			<Line-Item>
				<LineNumber>
					<xsl:value-of select="position()" />
				</LineNumber>
				<SupplierItemCode>
					<xsl:value-of select="Товар/@Код" />
				</SupplierItemCode>
				<ItemDescription>
					<xsl:value-of select="normalize-space(substring-after(Товар, ' '))" />
				</ItemDescription>
				<QuantityDespatched>
					<xsl:value-of select="Количество" />
				</QuantityDespatched>
				<UnitOfMeasure>
					<xsl:choose>
						<xsl:when test="Единица = 'шт.'">
							<xsl:text>PCE</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>KGM</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</UnitOfMeasure>
				<UnitNetPrice>
					<xsl:value-of select="Цена" />
				</UnitNetPrice>
				<UnitGrossPrice>
					<xsl:value-of select="$price_with_vat" />
				</UnitGrossPrice>
				<TaxRate>
					<xsl:value-of select="СтавкаНДС" />
				</TaxRate>
				<NetAmount>
					<xsl:value-of select="$sum_without_vat" />
				</NetAmount>
				<TaxAmount>
					<xsl:value-of select="$vat_sum" />
				</TaxAmount>
				<GrossAmount>
					<xsl:value-of select="$sum_with_vat" />
				</GrossAmount>
			</Line-Item>
		</Line>
	</xsl:template>
	
	<xsl:template name="convert-date">
		<xsl:param name="date" />
		<!-- Parse date param to yy, mm & dd /-->
		<xsl:variable name="yy" select="substring($date, 7, 2)" />
		<xsl:variable name="mm" select="substring($date, 4, 2)" />
		<xsl:variable name="dd" select="substring($date, 1, 2)" />
		<!-- Return date in yyyy-mm-dd format /-->
		<xsl:value-of select="concat('20', $yy, '-', $mm, '-', $dd)" />
	</xsl:template>
</xsl:stylesheet>