/// Load vaccines information from CSV files and Globals
/// do ##class(diashenrique.util.Install).Load()
Class diashenrique.util.Install
{

/// Load method will call the ClassMethod inside diashenrique.util.Utils class
/// The initial sequence: 
/// kill previous data
/// read CSV with Locations info
/// populate Country class
/// populate Vaccination class
ClassMethod Load() As %Status
{
    Set sc = $$$OK

    kill ^LatitudeLongitude
    kill ^CountryD
    kill ^CountryI
    kill ^VaccinationsD

    do ##class(diashenrique.util.Utils).loadLatitudeLongitude()
    do ##class(diashenrique.util.Utils).readAndInsertCountry()
    do ##class(diashenrique.util.Utils).readFiles()
    do ##class(diashenrique.util.Utils).createGlobalSummary()
    do ##class(diashenrique.util.Utils).createSummaryHeader()
    do ##class(diashenrique.util.Utils).createTopList()


    Return sc
}

}
