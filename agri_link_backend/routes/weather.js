const express = require('express');
const router = express.Router();
const axios = require('axios');

// Cache weather data in memory
const weatherCache = {};

// Default ADM4: Gambir, Jakarta Pusat
const DEFAULT_ADM4 = '31.71.01.1001';

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

        // Use BMKG API directly with default ADM4
        console.log('[WEATHER] Fetching weather for ADM4:', DEFAULT_ADM4);
        
        const weatherUrl = `https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=${DEFAULT_ADM4}`;
        console.log('[WEATHER] Weather URL:', weatherUrl);
        
        const weatherResponse = await axios.get(weatherUrl, {
            timeout: 10000,
            validateStatus: (status) => status < 500,
        });

        console.log('[WEATHER] Weather response status:', weatherResponse.status);
        console.log('[WEATHER] Weather response data keys:', weatherResponse.data ? Object.keys(weatherResponse.data) : 'no data');
        
        if (weatherResponse.status !== 200) {
            throw new Error(`BMKG Weather API returned status ${weatherResponse.status}: ${JSON.stringify(weatherResponse.data).substring(0, 200)}`);
        }
        
        if (!weatherResponse.data) {
            throw new Error('BMKG Weather API returned no data');
        }
        
        // Struktur response BMKG: { lokasi: {...}, data: [{ lokasi: {...}, cuaca: [[...]] }] }
        const weatherDataArray = weatherResponse.data.data;
        if (!Array.isArray(weatherDataArray) || weatherDataArray.length === 0) {
            console.error('[WEATHER] Unexpected weather data structure:', JSON.stringify(weatherResponse.data).substring(0, 500));
            throw new Error('BMKG Weather API returned invalid data structure - expected data array');
        }

        const areaData = weatherDataArray[0];
        const lokasiRoot = weatherResponse.data.lokasi || areaData?.lokasi || {};
        if (!areaData || !areaData.cuaca) {
            console.error('[WEATHER] Area data or cuaca missing:', {
                hasAreaData: !!areaData,
                hasCuaca: !!areaData?.cuaca,
                areaDataKeys: areaData ? Object.keys(areaData) : []
            });
            throw new Error('BMKG Weather API returned data without cuaca array');
        }

        console.log('[WEATHER] Area data found:', !!areaData);
        console.log('[WEATHER] Cuaca array exists:', !!areaData.cuaca);
        console.log('[WEATHER] Cuaca array length:', Array.isArray(areaData.cuaca) ? areaData.cuaca.length : 0);

        const cuaca = Array.isArray(areaData.cuaca) ? areaData.cuaca : [];

        const mapWeatherEntry = (entry) => ({
            datetime: entry?.local_datetime || entry?.datetime || null,
            temperature: entry?.t ?? null,
            humidity: entry?.hu ?? null,
            precipitation: entry?.tp ?? null,
            weather_code: entry?.weather ?? null,
            weather_desc: entry?.weather_desc ?? null,
            weather_desc_en: entry?.weather_desc_en ?? null,
            wind_speed: entry?.ws ?? null,
            wind_dir: entry?.wd ?? null,
            wind_dir_to: entry?.wd_to ?? null,
            wind_deg: entry?.wd_deg ?? null,
            cloud_cover: entry?.tcc ?? null,
            visibility: entry?.vs_text ?? entry?.vs ?? null,
            analysis_date: entry?.analysis_date ?? null,
            icon: entry?.image ?? null,
        });

        const currentSlot = cuaca.length > 0 && Array.isArray(cuaca[0]) && cuaca[0].length > 0
            ? mapWeatherEntry(cuaca[0][0])
            : null;

        const forecastSlots = cuaca
            .map((slot) => (Array.isArray(slot) && slot.length > 0 ? mapWeatherEntry(slot[0]) : null))
            .filter((item) => item !== null);

        const payload = {
            location: {
                provinsi: lokasiRoot?.provinsi || null,
                kotkab: lokasiRoot?.kotkab || null,
                kecamatan: lokasiRoot?.kecamatan || null,
                desa: lokasiRoot?.desa || null,
                lon: lokasiRoot?.lon ?? null,
                lat: lokasiRoot?.lat ?? null,
                timezone: lokasiRoot?.timezone || null,
            },
            current: currentSlot,
            forecast: forecastSlots,
            source: 'BMKG',
        };

        // Cache the result
        weatherCache[cacheKey] = {
            data: payload,
            timestamp: Date.now()
        };

        res.json({
            success: true,
            message: 'Weather data retrieved',
            data: payload,
            cached: false
        });
    } catch (error) {
        console.error('[WEATHER] Get weather error:', error.message);
        console.error('[WEATHER] Error stack:', error.stack);
        if (error.response) {
            console.error('[WEATHER] Error response data:', error.response.data);
        }
        res.status(500).json({
            success: false,
            message: `Failed to get weather data: ${error.message}`,
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

// Get All Provinces - gunakan hardcoded list
router.get('/provinces/list', async (req, res) => {
    try {
        console.log('[WEATHER] Returning simplified provinces list');
        const provinces = [
            { id: '31', name: 'DKI Jakarta' },
        ];

        res.json({
            success: true,
            message: 'Provinces retrieved',
            data: provinces
        });
    } catch (error) {
        console.error('[WEATHER] Get provinces error:', error.message);
        res.status(500).json({
            success: false,
            message: `Failed to get provinces: ${error.message}`,
            data: null
        });
    }
});

module.exports = router;
