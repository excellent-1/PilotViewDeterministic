using StackExchange.Redis;
using System.Text.Json;
using System.Threading;

class Simulator {
    static void Main() {
        var redis = ConnectionMultiplexer.Connect("localhost:6379"); // Connects to a Redis server running on localhost port 6379
        var pub = redis.GetSubscriber(); // Gets a Redis pub/sub channel interface for publishing messages
        var db = redis.GetDatabase(); // Gets a Redis database interface for storing key/value data
        var rng = new DeterministicRng(12345); // Creates a deterministic random generator with a fixed seed so outputs are reproducible
        var engine = new EngineSystem(rng); // Creates an engine simulation system that uses the deterministic RNG
        var threats = new ThreatSystem(rng); // Creates a threat simulation system that uses the deterministic RNG
        var interval = TimeSpan.FromSeconds(1.0 / 777.0); // 777 Hz update rate means we want to update every 1/777 seconds, so we calculate that interval here
        var sw = new System.Diagnostics.Stopwatch(); // Switching to a high-precision stopwatch for accurate timing to reach exactly 777Hz

        while (true) {  // Infinite loop — produces simulation updates continuously
            sw.Restart(); // Restart the stopwatch at the beginning of each loop iteration to measure how long the update takes
            var packet = new {
                position = new { lat = 33.64, lon = -84.42 }, // Hard‑coded aircraft position
                engine = engine.GetData(), // Gets current simulated engine data
                threats = threats.GenerateThreats(10) // Generates 10 simulated threats
            };

            string json = JsonSerializer.Serialize(packet); // Converts the packet object into a JSON string
            db.HashSet("f35:state", new HashEntry[] { new HashEntry("latest", json) }); // Saves the JSON into Redis under hash key "f35:state" with field "latest"
            // pub.Publish("f35:realtime", json); // Publishes the JSON message on Redis pub/sub channel "f35:realtime" this allows real-time updates to any subscribers
            pub.Publish(RedisChannel.Literal("f35:realtime"), json); // That removes the warning and prevents exit code 134 (which is caused by .NET treating this obsolete API usage as an error in CI).
            while(sw.Elapsed < interval) { } // Busy-wait hit exact timing of a consistent 777Hz update rate
        }
    }
}
