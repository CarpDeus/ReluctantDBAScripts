SELECT log.name AS [Name] 
                , CASE WHEN N'U' = log.type THEN 0 
                        WHEN N'G' = log.type THEN 1 
                        WHEN N'S' = log.type THEN 2 
                        WHEN N'C' = log.type THEN 3 
                        WHEN N'K' = log.type THEN 4 
                        END AS [LoginType] 
                , log.is_disabled AS [IsDisabled] 
                , log.create_date AS [CreateDate] 
			    , log.Default_database_name [DefaultDatabase]
        FROM 
                sys.server_principals AS log 
        WHERE 
                (log.type in ('U', 'G', 'S', 'C', 'K') 
                        AND log.principal_id not between 101 and 255 
                        AND log.name <> N'##MS_AgentSigningCertificate##') 
        ORDER BY 
			 2,1 ASC