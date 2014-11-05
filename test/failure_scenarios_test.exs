Code.require_file "test_helper.exs", __DIR__

defmodule FailureScenariosTest do
  use ExUnit.Case
  import ExqTestUtil

  defmodule PerformWorker do
    def perform do
      send :exqtest, {:worked}
    end
  end

  setup do
    TestRedis.start
    on_exit fn ->
      wait
      TestRedis.stop
    end
    :ok
  end

  test "handle Redis connection lost on listener" do
    {:ok, exq} = Exq.start_link([port: 6555 ])

    # Stop Redis and wait for a bit
    TestRedis.stop
    wait_long

    # Starting Redis again, things should be back to normal
    TestRedis.start
    TestExq.assert_exq_up(exq)
    Exq.stop(exq)
  end

  test "handle Redis connection lost on enqueue" do
    # Start Exq but don't listen to any queues
    {:ok, exq} = Exq.start_link([port: 6555, queues: []])

    # Stop Redis
    TestRedis.stop

    # enqueue with redis stopped
    enq_result = Exq.enqueue(exq, "default", "ExqTest.PerformWorker", [])
    assert enq_result ==  {:error, :no_connection}

    # Starting Redis again and things should be back to normal
    wait_long
    TestRedis.start
    assert_exq_up(exq)
    Exq.stop(exq)
  end

  test "handle enqueue fails due to incorrect Redis datastructure type" do
  end

  test "handle invalid JSON on dequeued job" do
  end

  test "workers should complete even if other errors happen" do
  end

  test "workers should if manager shuts down" do
  end

  test "workers should time out on shutdown when manager shutsdown" do
  end

  test "stats error should not crash manager" do
  end

  test "workers limited to pool size (move this to exq)" do
  end

  test "it should use multi for setting up queue" do
  end

end
