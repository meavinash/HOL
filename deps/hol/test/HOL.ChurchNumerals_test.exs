defmodule ChurchNumerals.Tests do
  @moduledoc false
  use ExUnit.Case
  import LoggerHelper
  import HOL.Data
  import HOL.Terms
  import HOL.ChurchNumerals

  doctest HOL.ChurchNumerals

  setup do
    set_logger_warning()
  end

  # setup_all do
  #  {:ok, %{}}
  # end

  test "succ_0" do
    assert mk_num(1) == succ(mk_num(0))
  end

  test "succ_3" do
    assert mk_num(4) == succ(mk_num(3))
  end

  test "succ_10" do
    assert mk_num(11) == succ(mk_num(10))
  end

  test "plus_3_5" do
    assert plus(mk_num(3), mk_num(5)) == mk_num(8)
  end

  test "plus_16_4" do
    assert plus(mk_num(16), mk_num(4)) == mk_num(20)
  end

  test "plus_0_0" do
    assert plus(mk_num(0), mk_num(0)) == mk_num(0)
  end

  test "mult_0_0" do
    assert mult(mk_num(0), mk_num(0)) == mk_num(0)
  end

  test "mult_4_8" do
    assert mult(mk_num(4), mk_num(8)) == mk_num(32)
  end

  test "mult_0_5" do
    assert mult(mk_num(0), mk_num(5)) == mk_num(0)
  end

  test "mult_1_6" do
    assert mult(mk_num(1), mk_num(6)) == mk_num(6)
  end

  test "mult_10_10" do
    assert mult(mk_num(10), mk_num(10)) == mk_num(100)
  end

  # @tag :skip
  # test "exp_1_1" do
  #   assert exp(mk_num(1), mk_num(1)) == mk_num(1)
  # end

  # @tag :skip
  # test "exp_0_5" do
  #   assert exp(mk_num(0), mk_num(5)) == mk_num(0)
  # end

  # @tag :skip
  # test "exp_3_0" do
  #   assert exp(mk_num(3), mk_num(0)) == mk_num(1)
  # end

  # @tag :skip
  # test "exp_3_3" do
  #   assert exp(mk_num(3), mk_num(3)) == mk_num(27)
  # end

  # @tag :skip
  # test "exp_5_2" do
  #   assert exp(mk_num(5), mk_num(2)) == mk_num(25)
  # end

  test "mult_0_x" do
    t_x = mk_free_var_term("x", mk_type(:i, [mk_type(:i, [mk_type(:i)]), mk_type(:i)]))
    assert mult(mk_num(0), t_x) == mk_num(0)
    assert mult(t_x, mk_num(0)) != mk_num(0)
  end

  test "mult_1_x" do
    t_x = mk_free_var_term("x", mk_type(:i, [mk_type(:i, [mk_type(:i)]), mk_type(:i)]))
    assert mult(mk_num(1), t_x) == t_x
    assert mult(t_x, mk_num(1)) == t_x
  end

  test "plus_0_x" do
    t_x = mk_free_var_term("x", mk_type(:i, [mk_type(:i, [mk_type(:i)]), mk_type(:i)]))
    assert plus(mk_num(0), t_x) == t_x
    assert plus(t_x, mk_num(0)) == t_x
  end
end
