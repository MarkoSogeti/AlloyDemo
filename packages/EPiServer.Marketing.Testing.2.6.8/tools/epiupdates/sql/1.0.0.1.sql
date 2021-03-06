--beginvalidatingquery
		-- mar-1205: we used to check for a core cms stored proc but, there are times when our scripts get run before the core ones do and it would blow everything up
		-- so now we just let our scripts run.  We use the same connection string as core and have a dependency on it as well, so it's not necessary
		-- to check.
		 select 1, 'Upgrading database'
--endvalidatingquery

-- Create MultivariateTest Tables to Store MultivariateTest Information.
DECLARE @CurrentMigration [nvarchar](max)

IF object_id('[dbo].[__MigrationHistory]') IS NOT NULL
    SELECT @CurrentMigration =
        (SELECT TOP (1) 
        [Project1].[MigrationId] AS [MigrationId]
        FROM ( SELECT 
        [Extent1].[MigrationId] AS [MigrationId]
        FROM [dbo].[__MigrationHistory] AS [Extent1]
        WHERE [Extent1].[ContextKey] = N'Testing.Migrations.Configuration'
        )  AS [Project1]
        ORDER BY [Project1].[MigrationId] DESC)

IF @CurrentMigration IS NULL
    SET @CurrentMigration = '0'

IF @CurrentMigration < '201609091719244_Initial'
BEGIN
    CREATE TABLE [dbo].[tblABTest] (
        [Id] [uniqueidentifier] NOT NULL,
        [Title] [nvarchar](max) NOT NULL,
        [Description] [nvarchar](max),
        [Owner] [nvarchar](max) NOT NULL,
        [OriginalItemId] [uniqueidentifier] NOT NULL,
        [State] [int] NOT NULL,
        [StartDate] [datetime] NOT NULL,
        [EndDate] [datetime] NOT NULL,
        [ParticipationPercentage] [int] NOT NULL,
        [LastModifiedBy] [nvarchar](100),
        [ExpectedVisitorCount] [int],
        [ActualVisitorCount] [int] NOT NULL,
        [ConfidenceLevel] [float] NOT NULL,
        [ZScore] [float] NOT NULL,
        [IsSignificant] [bit] NOT NULL,
        [CreatedDate] [datetime] NOT NULL,
        [ModifiedDate] [datetime] NOT NULL,
        CONSTRAINT [PK_dbo.tblABTest] PRIMARY KEY ([Id])
    )
    CREATE TABLE [dbo].[tblABKeyPerformanceIndicator] (
        [Id] [uniqueidentifier] NOT NULL,
        [TestId] [uniqueidentifier] NOT NULL,
        [KeyPerformanceIndicatorId] [uniqueidentifier],
        [CreatedDate] [datetime] NOT NULL,
        [ModifiedDate] [datetime] NOT NULL,
        CONSTRAINT [PK_dbo.tblABKeyPerformanceIndicator] PRIMARY KEY ([Id])
    )
    CREATE INDEX [IX_TestId] ON [dbo].[tblABKeyPerformanceIndicator]([TestId])
    CREATE TABLE [dbo].[tblABVariant] (
        [Id] [uniqueidentifier] NOT NULL,
        [TestId] [uniqueidentifier] NOT NULL,
        [ItemId] [uniqueidentifier] NOT NULL,
        [ItemVersion] [int] NOT NULL,
        [IsWinner] [bit] NOT NULL,
        [Conversions] [int] NOT NULL,
        [Views] [int] NOT NULL,
        [IsPublished] [bit] NOT NULL,
        [CreatedDate] [datetime] NOT NULL,
        [ModifiedDate] [datetime] NOT NULL,
        CONSTRAINT [PK_dbo.tblABVariant] PRIMARY KEY ([Id])
    )
    CREATE INDEX [IX_TestId] ON [dbo].[tblABVariant]([TestId])
    ALTER TABLE [dbo].[tblABKeyPerformanceIndicator] ADD CONSTRAINT [FK_dbo.tblABKeyPerformanceIndicator_dbo.tblABTest_TestId] FOREIGN KEY ([TestId]) REFERENCES [dbo].[tblABTest] ([Id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[tblABVariant] ADD CONSTRAINT [FK_dbo.tblABVariant_dbo.tblABTest_TestId] FOREIGN KEY ([TestId]) REFERENCES [dbo].[tblABTest] ([Id]) ON DELETE CASCADE
    IF object_id('[dbo].[__MigrationHistory]') IS NULL
    BEGIN 
    CREATE TABLE [dbo].[__MigrationHistory] (
        [MigrationId] [nvarchar](150) NOT NULL,
        [ContextKey] [nvarchar](300) NOT NULL,
        [Model] [varbinary](max) NOT NULL,
        [ProductVersion] [nvarchar](32) NOT NULL,
        CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY ([MigrationId], [ContextKey])
    )
    END
    INSERT [dbo].[__MigrationHistory]([MigrationId], [ContextKey], [Model], [ProductVersion])
    VALUES (N'201609091719244_Initial', N'Testing.Migrations.Configuration',  0x1F8B0800000000000400ED5C5B6FE336167E5FA0FF41D0D3EE22B592999736B05B649CA430763209C699EC625F06B474EC10A52857A4521B457F591FFA93F62FEC91AD0B4989B22E6E90B4833CC4E6E523CFE1E1B9F09CE47FBFFD3EFE7E1332E7096241233E71CF46A7AE03DC8F02CA57133791CBAFBF71BFFFEEABBF8DAF8270E33CE4E3DEA6E370261713F751CAF5B9E709FF1142224621F5E348444B39F2A3D02341E4BD393DFDD63B3BF300215CC4729CF1C7844B1AC2EE0B7E9D46DC87B54C08BB890260226BC79EF90ED5F94042106BE2C3C4BDBAA3738871C7A31B12FF0812373ABA07B1FB7D4998EB5C304A705B73604BD7219C479248DCF4F927017319477C355F630361F7DB35E0B82561023262CECBE16DE93A7D93D2E5951373283F11320A3B029EBDCD18E599D37BB1DB2D1889ACBC4296CB6D4AF58E9D1317B975F12E659DEB98AB9D4F599C8E3CC8EED11E75776CA302F0C4C9869C1422839295FE9C38D384C92486098744C6849D3877C98251FF5FB0BD8F7E043EE10963EABE71E7D8A73560D35D1CAD2196DB8FB0CCA89905AEE3E9F33C7362314D99B327F38784E2E70FB836593028A4C26B9C7E4F25831C01650B09769D1BB2790F7C251F272E7E749D6BBA81206FC9603F718A570C27C93881CECB5E82F063BADE4BC5E0C59BD7BAFD9943FCFC24DEC6744539613309E1C0439AA3449787844A2115D3543CB38EEE70B1BC5420D3CFF7A8CB3A235DF1E0283877B821EAD3F5EEE2DE41EC03976455E0CEB87CFBA633E87B22245E6ABAA410BCDB3608C0D9E9E911C4EC6AB3065F42F0400595513C8DD03E180434035CF8A9F56898DE917EB4484B1AA02584F7F004AC38A4089555F723FAEFDC8F621808321373BAE278223E29A97B17450C08EF4E5F0C286FC711C05C4EFA817D204F74B5975D1D1695374AF3328AD12EF930E301128E872B5CE723B0DD04F148D7E59DB68CFFAC98B9EB380A3F466C6FFB0E8EFF7C4FE215A4AC8E3A4C9A47095EC1F6643E9098E2815AC9CAFAAD6454FAEBB65D1D54B7CDB157FA08873C070B238EE84A5856F8ABF81648E440080B034DD457AF28949BF15C9A21BF3D9D34437E2FFB5EB9EC121FF18A65885FAE546B1B3CDC1F4D21322E0F735166E2DF942BDE796F5720E259FC2F866DE881C2CF03216662275EE21182BF808773507175B7FD358AC9EE20B4534449A8AB2125769A896B4656E523CA711453BAA4D0A2B4C10A0AA3910062B64508553CF573BA817001712E899CF8923E21510F8425D8705A39576DFC853EFAAC79F465C4CBB1D5E046478EFD47840E8AF16FAB27B73F23B5F14288C8A7BB5338E8B429F2A5EF034354A78F55D4626DABA778832747D7785678F213F79F152E745CBD707BB5D5F37BA32F76E69A16EA965F0203094E7A90E96BDD94089F04D5DB8CDC0EF416346A1063D04D09435D2A500A2997550B48791AA4B31E2419582DED69BAD76255B3E712D6805782CB1EE7DB663BB9ADAD6EA958D960EB212E8E3D45A40F4A7A557336C856831AD564A970C03A496E4380F65A24D54AC2F348A6F57C5E9824EE8D18CE9138A3D4F54492051190B6C3A6CE7DFF849D7B4329B2E732539C52DC39C8DC22EC9880AE5669B2AB625411491DC3FEBA52076AD5E10756291F37EA508BFB64A028EC2DA1DAC571CAD42EF19F291B3D0D5F417E137F2B82D8D3CE298B1502616A009D93EDB85CE374D672F5808A6DAF6415424A7969E6925DA70EE24AEE041757B84C447AFB4C649EB1F42C29CBF10D59AFD1CB545298598B33DFE72FA75FCFBBE7F2C23D86E78B9A945EB1DB62251418B202A3378DF402B8A6B190B94A729D69105686990ACB72C5F3D5749D543DB6FCDEE7E3D3CFD9ABFF81A0C02A592557AF91D030351629CDA01C7EC3DC5D5A993012D73C2F4C239684DC6EB8ECB3B364A00A9035B5C7D0327B2A92D6D11E2FCBDEA9485953070C2315A781197DED51B3005205CB9A3A61E4A93803276F6E8F5524E354A4A2B13D8E3519A7E25A07B55FC7CCCFA9F0665F072ED4A6E13496D48E68BF425D9E4EC5AFEB6F8F5EC9DAA9D095CEF6B879FE4E85CBDBDAA318093C4DD5E85D1D28565FB9346AD58EF678FA4B970AA8F75411C79EA1922BFE76C51454C215DDB2B4B23B563FEBC886C8E601F7B24CADC1FE20539585449AADB28449769486F4920ADC30EC8B98B716F3C2313EB258E721582F31B64E7EC9625BE7C774F75FB42C8E09557474B10D793247370B796B271B58A6730CFB5776B4C7CBB23A2A52D6D4853A25ADA313A8747C51074677251C358714AB1761A9117E8EB350F070596D2536DC0F711D64D513BA4D1817CEB702857B940E18CD7F625346217556F20137041D18BC8EFBB48B8BA1EB374631EECB298CF5840858DBEAD867CF6E279CFE9440EAABCA54F8E26185A9FC89C4FE2389FF1E92CD3F8E516C6A05EC5C503A6C6BF545A28399A7158CD254C287968806F8591EA144B437CE8112D13E44D61788E6075A2D11ED26254DF5A0C66EDBC0D9AB43FB906EA90D5DB2887407D34B43FB61D456862E680FCAAA3513BD65AEAE66A225D831EA105FA1D2D6CA93AA7095B411120B9B89FBCB6EFEB933FBCFE73DC489731BA33D3E774E9D5F8F5F34D844679BBBF80A65AC36CEF922533DABE60613555341D7478D9BF573BD1466B576AECF56B4CAB97EB454EAE6FE84FAFFF8354D7982F3D92B31DAE47C8F5648D5B7ECC39A7C7BC6F2A39756E331BCDAE865C85C517BD1B3C4E955C894FD75F305D60955B3F39697E16AF570531DD0FE1D0775EF22C2C3CEFCB445DB32A126B5D3A950C8BA8DBEA545AAB036161759577E25E547FA211BC50DFDAA894CB0B667F092EA8986B0C5101C339FF187140C555F62518328FF0601F597C028BE8048FF2902075FD31DC598195F46B90A3376940F31DD319004DD2F7211A3D74D7C89DD3E08B1FB73DEACAEFC2A5C4030E3B7895C2712498670C1B4F281541536ADBFAB8AD2F73CBEDD3D1D8A639080DBA4A90779CBDF259495F5F0D7351EA40522D5B13F00B6EFCF1255B684D5B640FAB02BCB6F0394B1AF300DF710AE1982895B3E27CADF0174D8DB2701EF6145FC6DFEA06E07397C103ADBC79794AC62128A0CA39C8F5F51868370F3DDFF01F85FD6DF0D440000 , N'6.1.3-40302')
END


GO
