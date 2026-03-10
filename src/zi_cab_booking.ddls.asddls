@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define root view entity ZI_CAB_BOOKING
  as select from zcab_booking
  association [0..1] to ZI_CAB_DRIVER as _Driver
    on $projection.DriverId = _Driver.DriverId
{
  key booking_uuid       as BookingUuid,
      booking_no         as BookingNo,
      customer_name      as CustomerName,
      pickup_location    as PickupLocation,
      drop_location      as DropLocation,
      driver_id          as DriverId,
      vehicle_number     as VehicleNumber,
      status             as Status,
      /* --- UI Color Logic --- */
      case status
        when 'Booked'          then 5  
        when 'Driver Assigned' then 3  
        when 'Trip Started'    then 2  
        when 'Completed'       then 3  
        else 0
      end as StatusCriticality,
      booking_date       as BookingDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      fare_amount        as FareAmount,
      currency_code      as CurrencyCode,
      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at         as CreatedAt,
       @Semantics.user.lastChangedBy: true
      last_changed_by    as LastChangedBy,
        @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at    as LastChangedAt,
       @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed as LocalLastChanged,
      
      _Driver
}

