@EndUserText.label: 'Cab Booking - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_CAB_BOOKING
  provider contract transactional_query
  as projection on ZI_CAB_BOOKING
{
  key BookingUuid,
      BookingNo,
      CustomerName,

      @Consumption.valueHelpDefinition: [{ 
        entity: { name: 'ZC_CAB_DRIVER', element: 'DriverId' },
        additionalBinding: [{ localElement: 'VehicleNumber', element: 'VehicleNumber' }] 
      }]
      DriverId,

      VehicleNumber,
      PickupLocation,
      DropLocation,
      Status,
      StatusCriticality,
      
      BookingDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      FareAmount,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChanged,

      /* Redirecting the interface association to the projection view */
      _Driver : redirected to ZC_CAB_DRIVER
}

