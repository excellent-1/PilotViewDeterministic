using System;

public class DeterministicRng {
    private Random rng;
    public DeterministicRng(int seed) {
        rng = new Random(seed);
    }
    public double NextDouble(double min, double max) {
        return min + rng.NextDouble() * (max - min);
    }
}
