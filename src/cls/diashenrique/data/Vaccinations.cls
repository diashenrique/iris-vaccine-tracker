Class diashenrique.data.Vaccinations Extends (%Persistent, %JSON.Adaptor)
{

/// Location 
Property CountryId As diashenrique.data.Country;

/// Date
Property DateReport As %Date;

/// Vaccine
Property Vaccine As %String;

/// Total Vaccinations
Property TotalVaccinations As %Integer;

/// People Vaccinated
Property PeopleVaccinated As %Integer;

/// People Fully Vaccinated
Property FullyVaccinated As %Integer;

Storage Default
{
<Data name="VaccinationsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CountryId</Value>
</Value>
<Value name="3">
<Value>DateReport</Value>
</Value>
<Value name="4">
<Value>Vaccine</Value>
</Value>
<Value name="5">
<Value>TotalVaccinations</Value>
</Value>
<Value name="6">
<Value>PeopleVaccinated</Value>
</Value>
<Value name="7">
<Value>FullyVaccinated</Value>
</Value>
</Data>
<DataLocation>^VaccinationsD</DataLocation>
<DefaultData>VaccinationsDefaultData</DefaultData>
<IdLocation>^VaccinationsD</IdLocation>
<IndexLocation>^VaccinationsI</IndexLocation>
<StreamLocation>^VaccinationsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
