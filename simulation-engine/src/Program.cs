using StackExchange.Redis;
using System.Text.Json;
using System.Threading;

class Simulator {
    static void Main() {
        ConnectionMultiplexer redis = null;
        var redisUrl = "rediss://default:ARYqAAImcDFhZDIzN2JmOGRiMGE0M2EzYjc1ZjFjN2UxNTMwN2YxYnAxNTY3NA@normal-akita-5674.upstash.io:6379";
        var options = new ConfigurationOptions
        {   EndPoints = { "normal-akita-5674.upstash.io:6379" },
            Password = "ARYqAAImcDFhZDIzN2JmOGRiMGE0M2EzYjc1ZjFjN2UxNTMwN2YxYnAxNTY3NA",
            User = "default",
            Ssl = true,
            AbortOnConnectFail = false
        };

        try
        {   redis = ConnectionMultiplexer.Connect(options); // Connects to a Redis server running on config
            Console.WriteLine("SUCCESS — Connected to Upstash!");
        }
        catch (Exception ex)
        {   Console.WriteLine("FAILED to connect:");
            Console.WriteLine(ex);
        }
        var pub = redis.GetSubscriber(); // Gets a Redis pub/sub channel interface for publishing messages
        var db = redis.GetDatabase(); // Gets a Redis database interface for storing key/value data
        var rng = new DeterministicRng(12345); // Creates a deterministic random generator with a fixed seed so outputs are reproducible
        var engine = new EngineSystem(rng); // Creates an engine simulation system that uses the deterministic RNG
        var threats = new ThreatSystem(rng); // Creates a threat simulation system that uses the deterministic RNG
        var interval = TimeSpan.FromSeconds(1.0 / 777.0); // 1.0 / 777.0 =  777 Hz update rate means we want to update every 1/777 seconds, so we calculate that interval here
        var sw = new System.Diagnostics.Stopwatch(); // Switching to a high-precision stopwatch for accurate timing to reach exactly 777Hz
        int hash_entry_count = 1;
        while (true) {  // Infinite loop — produces simulation updates continuously
            sw.Restart(); // Restart the stopwatch at the beginning of each loop iteration to measure how long the update takes
            var packet = new {
                position = new { lat = 33.64, lon = -84.42 }, // Hard‑coded aircraft position
                engine = engine.GetData(), // Gets current simulated engine data
                threats = threats.GenerateThreats(10) // Generates 10 simulated threats
            };

            string json_packet = JsonSerializer.Serialize(packet); // Converts the packet object into a JSON string
            db.HashSet("f35:state", new HashEntry[] { // Add a count to hash entry to see new entries insert in upstash in real time
                new HashEntry($"latest_{hash_entry_count}_{DateTime.Now:yyyy-MM-dd HH:mm:ss.fffffff}", json_packet) 
                }); // Saves the JSON into Redis under hash key "f35:state" with field "latest"
            pub.Publish(RedisChannel.Literal("f35:realtime"), json_packet); // That removes the warning and prevents exit code 134 (which is caused by .NET treating this obsolete API usage as an error in CI).
            //while(sw.Elapsed < interval) { } // Busy-wait hit exact timing of a consistent 777Hz update rate // Your CPU use is high (almost at 99%) because the loop is constantly checking sw.Elapsed millions of times per second.
            var remaining_time = interval - sw.Elapsed;
            if(remaining_time > TimeSpan.Zero)  
                Thread.Sleep(remaining_time); // Here my Thread.Sleep yields the thread to the OS so no CPU is wasted (almost 1% CPU usage)
            
            hash_entry_count++;
        }
    }
}
