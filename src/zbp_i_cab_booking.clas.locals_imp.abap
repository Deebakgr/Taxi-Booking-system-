CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      generateBookingNo           FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Booking~generateBookingNo,
      setInitialStatus            FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Booking~setInitialStatus,
      validateMandatory           FOR VALIDATE ON SAVE
        IMPORTING keys FOR Booking~validateMandatory,
      AssignDriver                FOR MODIFY
        IMPORTING keys FOR ACTION Booking~AssignDriver RESULT result,
      StartTrip                   FOR MODIFY
        IMPORTING keys FOR ACTION Booking~StartTrip RESULT result,
      CompleteTrip                FOR MODIFY
        IMPORTING keys FOR ACTION Booking~CompleteTrip RESULT result,
      get_global_authorizations   FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR Booking
        RESULT result,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
        IMPORTING keys REQUEST requested_authorizations FOR Booking
        RESULT result,
      fetchDriverDetails FOR DETERMINE ON MODIFY
            IMPORTING keys FOR Booking~fetchDriverDetails.
ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD generateBookingNo.
    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( BookingNo )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DELETE bookings WHERE BookingNo IS NOT INITIAL.
    CHECK bookings IS NOT INITIAL.

    SELECT MAX( booking_no ) FROM zcab_booking INTO @DATA(lv_max_no).

    DATA: lv_counter TYPE i.

    " --- FIX: Safe string handling to prevent ABAP Dumps ---
    IF lv_max_no IS INITIAL.
      lv_counter = 1000.
    ELSE.
      DATA(lv_len) = strlen( lv_max_no ).
      IF lv_len > 2.
        DATA(lv_numeric_part) = substring( val = lv_max_no off = 2 ).
        TRY.
            lv_counter = CONV i( lv_numeric_part ).
          CATCH cx_sy_conversion_no_number. " Catch dirty data
            lv_counter = 1000.
        ENDTRY.
      ELSE.
        lv_counter = 1000.
      ENDIF.
    ENDIF.

    MODIFY ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( BookingNo )
        WITH VALUE #( FOR booking IN bookings
                      INDEX INTO idx
                      ( %tky      = booking-%tky
                        BookingNo = |BK{ lv_counter + idx }| ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    MODIFY ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys
                      ( %tky  = key-%tky
                        Status = 'Booked' ) ).
  ENDMETHOD.

  METHOD assignDriver.
    MODIFY ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys
                      ( %tky   = key-%tky
                        Status = 'Driver Assigned' ) ).

    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_booking).

    result = VALUE #( FOR booking IN lt_booking (
                        %tky   = booking-%tky
                        %param = booking ) ).
  ENDMETHOD.

  METHOD StartTrip.
    MODIFY ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys
                      ( %tky  = key-%tky
                        Status = 'Trip Started' ) ).

    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_booking).

    result = VALUE #( FOR booking IN lt_booking
                      ( %tky   = booking-%tky
                        %param = booking ) ).
  ENDMETHOD.

  METHOD CompleteTrip.
    MODIFY ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys
                      ( %tky  = key-%tky
                        Status = 'Completed' ) ).

    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_booking).

    result = VALUE #( FOR booking IN lt_booking
                      ( %tky   = booking-%tky
                        %param = booking ) ).
  ENDMETHOD.

  METHOD validateMandatory.
    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( CustomerName PickupLocation DropLocation BookingDate CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      IF booking-CustomerName IS INITIAL.
        APPEND VALUE #(
          %tky = booking-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Customer Name is mandatory' )
        ) TO reported-booking.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
      ENDIF.
      " (Other validations remain the same)
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    " 1. ALWAYS grant basic Update/Delete rights first so Fiori doesn't crash/bounce
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #(
        %tky    = ls_key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.
    ENDLOOP.

    " 2. Then read the current status to handle the Action buttons
    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    " 3. Update the specific action permissions in the result table
    LOOP AT bookings INTO DATA(booking).
      ASSIGN result[ %tky = booking-%tky ] TO FIELD-SYMBOL(<ls_result>).
      IF sy-subrc = 0.
        <ls_result>-%action-AssignDriver = COND #( WHEN booking-Status = 'Booked' THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
        <ls_result>-%action-StartTrip    = COND #( WHEN booking-Status = 'Driver Assigned' THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
        <ls_result>-%action-CompleteTrip = COND #( WHEN booking-Status = 'Trip Started' THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%create              = if_abap_behv=>auth-allowed.
    result-%update              = if_abap_behv=>auth-allowed.
    result-%delete              = if_abap_behv=>auth-allowed.
    result-%action-AssignDriver = if_abap_behv=>auth-allowed.
    result-%action-StartTrip    = if_abap_behv=>auth-allowed.
    result-%action-CompleteTrip = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD fetchDriverDetails.
    " 1. Read the newly entered Driver ID from the Booking draft
    READ ENTITIES OF zi_cab_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( DriverId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking) WHERE DriverId IS NOT INITIAL.

      " 2. Look up the Vehicle Number from the Driver Master Table
      " The INTO clause is now at the very end, fixing the error.
      SELECT SINGLE vehicle_number
        FROM zcab_driver
        WHERE driver_id = @booking-DriverId
        INTO @DATA(lv_vehicle_no).

      IF sy-subrc = 0.
        " 3. Update the Booking draft with the fetched Vehicle Number
        MODIFY ENTITIES OF zi_cab_booking IN LOCAL MODE
          ENTITY Booking
            UPDATE FIELDS ( VehicleNumber )
            WITH VALUE #( ( %tky = booking-%tky
                            VehicleNumber = lv_vehicle_no ) ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
