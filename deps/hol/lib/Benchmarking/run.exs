LoggerHelper.set_logger_warning()

require Benchmarking.Unification

Benchee.run(%{
  "succ_6" => fn -> Benchmarking.Unification.succ(true, 6) end,
  "succ_6_first" => fn -> Benchmarking.Unification.succ(false, 6) end
})

Benchee.run(%{
  "xaa_faa" => fn -> Benchmarking.Unification.xaa_faa(true) end,
  "xaa_faa_first" => fn -> Benchmarking.Unification.xaa_faa(false) end
})

Benchee.run(%{
  "xfa_fxa_1" => fn -> Benchmarking.Unification.xfa_fxa(true, 1) end,
  "xfa_fxa_1_first" => fn -> Benchmarking.Unification.xfa_fxa(false, 1) end,
  "xfa_fxa_10" => fn -> Benchmarking.Unification.xfa_fxa(true, 10) end,
  "xfa_fxa_10_first" => fn -> Benchmarking.Unification.xfa_fxa(false, 10) end,
  "xfa_fxa_100" => fn -> Benchmarking.Unification.xfa_fxa(true, 100) end,
  "xfa_fxa_100_first" => fn -> Benchmarking.Unification.xfa_fxa(false, 100) end,
  "xfa_fxa_200" => fn -> Benchmarking.Unification.xfa_fxa(true, 200) end,
  "xfa_fxa_200_first" => fn -> Benchmarking.Unification.xfa_fxa(false, 200) end,
  "xfa_fxa_500" => fn -> Benchmarking.Unification.xfa_fxa(true, 500) end,
  "xfa_fxa_500_first" => fn -> Benchmarking.Unification.xfa_fxa(false, 500) end
})
