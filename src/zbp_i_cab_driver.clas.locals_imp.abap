CLASS lhc_Driver DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Driver RESULT result.
ENDCLASS.

CLASS lhc_Driver IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " This is a basic implementation that allows Update and Delete for all records.
    " In a real-world scenario, you would check the user's roles (AUTHORITY-CHECK) here.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #(
        %tky    = ls_key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
