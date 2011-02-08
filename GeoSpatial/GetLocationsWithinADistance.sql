USE GeoSpatialTesting
go
-- =============================================
-- Author:		Josef Finsel
-- Create date: 2008-10-16
-- Description:	Sample to display cities within 
--				a radius of a point.
-- =============================================
CREATE PROCEDURE GetLocationsWithinADistance
	@Latitude varchar(20),
	@Longitude varchar(20),
	@DistanceInMiles numeric(10,3)
AS

DECLARE @pPoint geography,
		@pString nvarchar(100)
-- Create the string version of the point based on the latitude and longitude passed in
SET @pString = 'POINT(' + @Longitude + ' ' + @Latitude + ')'

-- Create the actual point
set @pPoint = geography::STGeomFromText(@pString,4326)

-- Used for changing to miles
declare @metres float
declare @MetreConversion float
set @MetreConversion = 0.000621371192
set @metres = @DistanceInMiles / @MetreConversion

select GSID, City, StateCode,GeogCol1.STDistance(@pPoint)*@MetreConversion Miles from geospatialtesting where  
 GeogCol1.STDistance(@pPoint)<=@metres
 order by city

-- GetLocationsWithinADistance @Latitude='39.3311', @Longitude='-84.542897', @DistanceInMiles=20
