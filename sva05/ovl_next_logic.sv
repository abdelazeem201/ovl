// Accellera Standard V2.5 Open Verification Library (OVL).
// Accellera Copyright (c) 2005-2010. All rights reserved.

`ifdef OVL_SHARED_CODE

  integer i = 0;

  always @ (posedge clk) begin
    if (`OVL_RESET_SIGNAL != 1'b0) begin
      if (start_event == 1'b1) begin
        i <= num_cks;
      end
      else if (i > 1) begin
        i <= i - 1;
      end
    end
    else begin
      i <= 0;
    end
  end

`endif // OVL_SHARED_CODE

`ifdef OVL_ASSERT_ON

  property ASSERT_NEXT_START_WITHOUT_TEST_P;
  @(posedge clk)
  disable iff (`OVL_RESET_SIGNAL != 1'b1)
  start_event |-> ##num_cks test_expr;
  endproperty

  property ASSERT_NEXT_TEST_WITHOUT_START_P;
  @(posedge clk)
  disable iff (`OVL_RESET_SIGNAL != 1'b1)
  not ((!start_event) ##num_cks test_expr);
  endproperty

  property ASSERT_NEXT_NO_OVERLAP_P;
  @(posedge clk)
  disable iff (`OVL_RESET_SIGNAL != 1'b1)
  start_event |-> (i <= 1);
  endproperty

  wire fire_2state;
  reg fire_2state_start_without_test_expr,
      fire_2state_test_expr_without_start_event,
      fire_2state_no_overlap;

`ifdef OVL_SYNTHESIS
`else
  initial begin
    fire_2state_start_without_test_expr = 1'b0;
    fire_2state_test_expr_without_start_event = 1'b0;
    fire_2state_no_overlap = 1'b0;
  end
`endif

  assign fire_2state = (fire_2state_start_without_test_expr ||
                        fire_2state_test_expr_without_start_event ||
                        fire_2state_no_overlap) ? ovl_fire_2state_f(property_type) : 1'b0;

`ifdef OVL_XCHECK_OFF
   wire fire_xcheck = 0; 
`else
  `ifdef OVL_IMPLICIT_XCHECK_OFF
     wire fire_xcheck = 0; 
  `else

  property ASSERT_NEXT_XZ_ON_START_EVENT_P;
  @(posedge clk)
  disable iff (`OVL_RESET_SIGNAL != 1'b1)
  (!($isunknown(start_event)));
  endproperty

  property ASSERT_NEXT_XZ_ON_TEST_EXPR_P;
  @(posedge clk)
  disable iff (`OVL_RESET_SIGNAL != 1'b1)
  (check_missing_start || $past(start_event,num_cks)) |-> (!($isunknown(test_expr)));
  endproperty

  wire fire_xcheck;
  reg fire_xcheck_start_event, fire_xcheck_test_expr;

`ifdef OVL_SYNTHESIS
`else
  initial begin
    fire_xcheck_start_event = 1'b0;
    fire_xcheck_test_expr = 1'b0;
  end
`endif

  assign fire_xcheck = (fire_xcheck_start_event || fire_xcheck_test_expr) ?
                       ovl_fire_xcheck_f(property_type) : 1'b0;

  `endif // OVL_IMPLICIT_XCHECK_OFF
`endif // OVL_XCHECK_OFF

  generate

    case (property_type)
      `OVL_ASSERT_2STATE,
      `OVL_ASSERT: begin : ovl_assert
        if (num_cks > 0) begin : a_assert_next_start_without_test
          A_ASSERT_NEXT_START_WITHOUT_TEST_P:
          assert property (ASSERT_NEXT_START_WITHOUT_TEST_P)
          fire_2state_start_without_test_expr <= 1'b0;
          else begin
            ovl_error_t(`OVL_FIRE_2STATE,"Test expression is not asserted after elapse of num_cks cycles from start event");
            fire_2state_start_without_test_expr <= 1'b1;
          end

          if (check_missing_start) begin : a_assert_next_test_without_start
            A_ASSERT_NEXT_TEST_WITHOUT_START_P:
            assert property (ASSERT_NEXT_TEST_WITHOUT_START_P)
            fire_2state_test_expr_without_start_event <= 1'b0;
            else begin
              ovl_error_t(`OVL_FIRE_2STATE,"Test expresson is asserted  without a corresponding start_event");
              fire_2state_test_expr_without_start_event <= 1'b1; 
            end
          end

          if (!check_overlapping) begin : a_assert_next_no_overlap
            A_ASSERT_NEXT_NO_OVERLAP_P:
            assert property (ASSERT_NEXT_NO_OVERLAP_P)
            fire_2state_no_overlap <= 1'b0;
            else begin
              ovl_error_t(`OVL_FIRE_2STATE,"Illegal overlapping condition of start event is detected");
              fire_2state_no_overlap <= 1'b1;
            end
          end


`ifdef OVL_XCHECK_OFF
  //Do nothing
`else
  `ifdef OVL_IMPLICIT_XCHECK_OFF
    //Do nothing
  `else
          A_ASSERT_NEXT_XZ_ON_START_EVENT_P:
          assert property (ASSERT_NEXT_XZ_ON_START_EVENT_P)
          fire_xcheck_start_event <= 1'b0;
          else begin
            ovl_error_t(`OVL_FIRE_XCHECK,"start_event contains X or Z");
            fire_xcheck_start_event <= 1'b1;
          end

          A_ASSERT_NEXT_XZ_ON_TEST_EXPR_P:
          assert property (ASSERT_NEXT_XZ_ON_TEST_EXPR_P)
          fire_xcheck_test_expr <= 1'b0;
          else begin
            ovl_error_t(`OVL_FIRE_XCHECK,"test_expr contains X or Z");
            fire_xcheck_test_expr <= 1'b1;
          end
  `endif // OVL_IMPLICIT_XCHECK_OFF
`endif // OVL_XCHECK_OFF

        end
      end
      `OVL_ASSUME_2STATE,
      `OVL_ASSUME: begin : ovl_assume
        if (num_cks > 0) begin : m_assert_next_start_without_test
          M_ASSERT_NEXT_START_WITHOUT_TEST_P:
          assume property (ASSERT_NEXT_START_WITHOUT_TEST_P);

          if (check_missing_start) begin : m_assert_next_test_without_start
            M_ASSERT_NEXT_TEST_WITHOUT_START_P:
            assume property (ASSERT_NEXT_TEST_WITHOUT_START_P);
          end
          if (!check_overlapping) begin : m_assert_next_no_overlap
            M_ASSERT_NEXT_NO_OVERLAP_P:
            assume property (ASSERT_NEXT_NO_OVERLAP_P);
          end


`ifdef OVL_XCHECK_OFF
  //Do nothing
`else
  `ifdef OVL_IMPLICIT_XCHECK_OFF
    //Do nothing
  `else
          M_ASSERT_NEXT_XZ_ON_START_EVENT_P:
          assume property (ASSERT_NEXT_XZ_ON_START_EVENT_P);

          M_ASSERT_NEXT_XZ_ON_TEST_EXPR_P:
          assume property (ASSERT_NEXT_XZ_ON_TEST_EXPR_P);
  `endif // OVL_IMPLICIT_XCHECK_OFF
`endif // OVL_XCHECK_OFF


        end
      end
      `OVL_IGNORE : begin : ovl_ignore
        // do nothing;
      end
      default     : initial ovl_error_t(`OVL_FIRE_2STATE,"");
    endcase

  endgenerate

`else // OVL_ASSERT_ON

  wire fire_2state = 0;
  wire fire_xcheck = 0;

`endif // OVL_ASSERT_ON

`ifdef OVL_COVER_ON
  wire fire_cover;
  reg fire_cover_start_event, fire_cover_overlapping_start_events;

`ifdef OVL_SYNTHESIS
`else
  initial begin
    fire_cover_start_event = 1'b0;
    fire_cover_overlapping_start_events = 1'b0;
  end
`endif

  assign fire_cover = (fire_cover_start_event || fire_cover_overlapping_start_events) ?
                      ovl_fire_cover_f(coverage_level) : 1'b0;

generate

    if (coverage_level != `OVL_COVER_NONE) begin : ovl_cover
     if (OVL_COVER_BASIC_ON) begin : ovl_cover_basic

      cover_start_event:
      cover property (@(posedge clk) ( (`OVL_RESET_SIGNAL != 1'b0) &&
                     start_event) ) begin
                       ovl_cover_t("start_event covered");
                       fire_cover_start_event <= 1'b1;
                     end
     end

     if (OVL_COVER_CORNER_ON) begin : ovl_cover_corner
      if (check_overlapping)

       cover_overlapping_start_events:
       cover property (@(posedge clk) ( (`OVL_RESET_SIGNAL != 1'b0) &&
                      (i > 1) && start_event) ) begin
                        ovl_cover_t("overlapping_start_events covered");
                        fire_cover_overlapping_start_events <= 1'b1;
                     end
     end
    end

endgenerate

`else // OVL_COVER_ON

   wire fire_cover = 0;

`endif // OVL_COVER_ON
