@EndUserText.label: 'Cab Driver - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_CAB_DRIVER
  provider contract transactional_query
  as projection on ZI_CAB_DRIVER
{
  key DriverId,
      @Search.defaultSearchElement: true
      DriverName,
      PhoneNumber,
      VehicleNumber,
      AvailabilityStatus
}
