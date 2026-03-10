@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Driver Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define root view entity ZI_CAB_DRIVER
  as select from zcab_driver
{
  key driver_id           as DriverId,
      driver_name         as DriverName,
      phone_number        as PhoneNumber,
      vehicle_number      as VehicleNumber,
      availability_status as AvailabilityStatus
}
