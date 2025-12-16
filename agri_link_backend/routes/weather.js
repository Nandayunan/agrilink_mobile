const express = require('express');
const router = express.Router();
const axios = require('axios');

// Cache weather data in memory
const weatherCache = {};

// Get Weather by Province
router.get('/province/:province', async (req, res) => {
    try {
        const { province } = req.params;

        // Check cache
        const cacheKey = `weather_${province}`;
        if (weatherCache[cacheKey] && Date.now() - weatherCache[cacheKey].timestamp < 3600000) {
            return res.json({
                success: true,
                message: 'Weather data retrieved (cached)',
                data: weatherCache[cacheKey].data,
                cached: true
            });
        }

        // Fetch from BMKG API
        // BMKG provides province list at: https://api.bmkg.go.id/publik/provinsi
        const provinceResponse = await axios.get('https://api.bmkg.go.id/publik/provinsi');
        const provinceData = provinceResponse.data.data.find(p => p.nama.toLowerCase().includes(province.toLowerCase()));

        if (!provinceData) {
            return res.status(404).json({
                success: false,
                message: 'Province not found',
                data: null
            });
        }

        // Get weather forecast
        const weatherResponse = await axios.get(`https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=${provinceData.id}`);

        const weatherData = weatherResponse.data.data;

        // Cache the result
        weatherCache[cacheKey] = {
            data: weatherData,
            timestamp: Date.now()
        };

        res.json({
            success: true,
            message: 'Weather data retrieved',
            data: weatherData,
            cached: false
        });
    } catch (error) {
        console.error('Get weather error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get weather data',
            data: null
        });
    }
});

// Get Weather by Coordinates (Latitude, Longitude)
router.get('/location/:lat/:lon', async (req, res) => {
    try {
        const { lat, lon } = req.params;

        // Check cache
        const cacheKey = `weather_${lat}_${lon}`;
        if (weatherCache[cacheKey] && Date.now() - weatherCache[cacheKey].timestamp < 3600000) {
            return res.json({
                success: true,
                message: 'Weather data retrieved (cached)',
                data: weatherCache[cacheKey].data,
                cached: true
            });
        }

        // Fetch from BMKG API using coordinates
        const weatherResponse = await axios.get(`https://api.bmkg.go.id/publik/prakiraan-cuaca?lon=${lon}&lat=${lat}`);

        const weatherData = weatherResponse.data.data;

        // Cache the result
        weatherCache[cacheKey] = {
            data: weatherData,
            timestamp: Date.now()
        };

        res.json({
            success: true,
            message: 'Weather data retrieved',
            data: weatherData,
            cached: false
        });
    } catch (error) {
        console.error('Get weather by location error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get weather data',
            data: null
        });
    }
});

// Get All Provinces
router.get('/provinces/list', async (req, res) => {
    try {
        const response = await axios.get('https://api.bmkg.go.id/publik/provinsi');

        const provinces = response.data.data.map(p => ({
            id: p.id,
            name: p.nama
        }));

        res.json({
            success: true,
            message: 'Provinces retrieved',
            data: provinces
        });
    } catch (error) {
        console.error('Get provinces error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get provinces',
            data: null
        });
    }
});

module.exports = router;
