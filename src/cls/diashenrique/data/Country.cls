/// Country
Class diashenrique.data.Country Extends (%Persistent, %JSON.Adaptor)
{

/// Name
Property Name As %String;

/// ISO 3166-1 alpha-2 codes are two-letter country codes defined in ISO 3166-1, 
/// part of the ISO 3166 standard published by the International Organization for Standardization (ISO), 
/// to represent countries, dependent territories, and special areas of geographical interest.  
Property Alpha2 As %String;

/// ISO 3166-1 alpha-3 codes are three-letter country codes defined in ISO 3166-1, 
/// part of the ISO 3166 standard published by the International Organization for Standardization (ISO), to represent countries, 
/// dependent territories, and special areas of geographical interest. 
/// They allow a better visual association between the codes and the country names than the two-letter alpha-2 codes (the third set of codes is numeric and hence offers no visual association).
Property Alpha3 As %String;

/// ISO 3166-1 numeric (or numeric-3) codes are three-digit country codes defined in ISO 3166-1, 
/// part of the ISO 3166 standard published by the International Organization for Standardization (ISO), 
/// to represent countries, dependent territories, and special areas of geographical interest. 
/// They are similar to the three-digit country codes developed and maintained by the United Nations Statistics Division, from which they originate in its UN M.49 standard. 
Property ISONumeric As %Integer;

/// Latitude
Property Latitude As %String;

/// Longitude
Property Longitude As %String;

/// Index Country Name
Index IndexCountryName On Name [ Unique ];

Storage Default
{
<Data name="CountryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Alpha2</Value>
</Value>
<Value name="4">
<Value>Alpha3</Value>
</Value>
<Value name="5">
<Value>ISONumeric</Value>
</Value>
<Value name="6">
<Value>Latitude</Value>
</Value>
<Value name="7">
<Value>Longitude</Value>
</Value>
</Data>
<DataLocation>^CountryD</DataLocation>
<DefaultData>CountryDefaultData</DefaultData>
<IdLocation>^CountryD</IdLocation>
<IndexLocation>^CountryI</IndexLocation>
<StreamLocation>^CountryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
