    import XCTest
    @testable import PodcastAPI

    final class PodcastAPITests: XCTestCase {
        func testSetApiKey() {
            var client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            client.search(parameters: parameters) { response in
                // Correct base url
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains(BASE_URL_TEST))
                }
                
                if let headers = response.request?.allHTTPHeaderFields {
                    if let userAgent = headers["User-Agent"] {
                        XCTAssertEqual(userAgent, DEFAULT_USER_AGENT)
                    } else {
                        XCTFail("Shouldn't be here")
                    }
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
            
            client = PodcastAPI.Client(apiKey: "fake api", synchronousRequest: true)
            client.search(parameters: parameters) { response in
                // Current base url
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains(BASE_URL_PROD))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct error
                if let error = response.error {
                    XCTAssertEqual(error, PodcastApiError.authenticationError)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testSearch() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            parameters["sort_by_date"] = "1"
            client.search(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/search"))
                    XCTAssertTrue(url.contains("q=startup"))
                    XCTAssertTrue(url.contains("sort_by_date=1"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["total"] > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
    
        func testSearchEpisodeTitles() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup222"
            parameters["podcast_id"] = "12334"
            client.searchEpisodeTitles(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/search_episode_titles"))
                    XCTAssertTrue(url.contains("q=startup222"))
                    XCTAssertTrue(url.contains("podcast_id=12334"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["total"] > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testTypeahead() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            parameters["show_podcasts"] = "1"
            client.typeahead(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/typeahead"))
                    XCTAssertTrue(url.contains("q=startup"))
                    XCTAssertTrue(url.contains("show_podcasts=1"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["terms"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testSpellcheck() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            client.spellcheck(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/spellcheck"))
                    XCTAssertTrue(url.contains("q=startup"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["tokens"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }        

        func testFetchRelatedSearches() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            client.fetchRelatedSearches(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/related_searches"))
                    XCTAssertTrue(url.contains("q=startup"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["terms"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }            
        
        func testFetchTrendingSearches() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            let parameters: [String: String] = [:]
            client.fetchTrendingSearches(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/trending_searches"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["terms"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        } 

        func testFetchBestPodcasts() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["genre_id"] = "23"
            client.fetchBestPodcasts(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/best_podcast"))
                    XCTAssertTrue(url.contains("genre_id=23"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["total"] > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testPodcastById() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            parameters["next_episode_pub_date"] = "1479154463000"
            client.fetchPodcastById(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts/\(id)"))
                    XCTAssertTrue(url.contains("next_episode_pub_date=1479154463000"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["episodes"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testEpisodeById() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            parameters["show_transcript"] = "1"
            client.fetchEpisodeById(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/episodes/\(id)"))
                    XCTAssertTrue(url.contains("show_transcript=1"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["podcast"]["rss"].stringValue.count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testFetchCuratedPodcastsListById() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            client.fetchCuratedPodcastsListById(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/curated_podcasts/\(id)"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["podcasts"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testFetchCuratedPodcastsLists() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["page"] = "2"
            client.fetchCuratedPodcastsLists(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/curated_podcasts"))
                    XCTAssertTrue(url.contains("page=2"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["total"] > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testFetchPodcastGenres() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["top_level_only"] = "1"
            client.fetchPodcastGenres(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/genres"))
                    XCTAssertTrue(url.contains("top_level_only=1"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["genres"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testFetchPodcastRegions() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            let parameters: [String: String] = [:]
            client.fetchPodcastRegions(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/regions"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["regions"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
                
        func testFetchPodcastLanguages() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            let parameters: [String: String] = [:]
            client.fetchPodcastLanguages(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/languages"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["languages"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testJustListen() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            let parameters: [String: String] = [:]
            client.justListen(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/just_listen"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["audio_length_sec"] > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testFetchRecommendationsForPodcast() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            parameters["safe_mode"] = "0"
            client.fetchRecommendationsForPodcast(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts/\(id)/recommendations"))
                    XCTAssertTrue(url.contains("safe_mode=0"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["recommendations"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testFetchRecommendationsForEpisode() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            parameters["safe_mode"] = "0"
            client.fetchRecommendationsForEpisode(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/episodes/\(id)/recommendations"))
                    XCTAssertTrue(url.contains("safe_mode=0"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["recommendations"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testFetchPlaylistById() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            parameters["sort"] = "recent_added_first"
            client.fetchPlaylistById(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/playlists/\(id)"))
                    XCTAssertTrue(url.contains("sort=recent_added_first"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["items"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testFetchMyPlaylists() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["page"] = "2"
            client.fetchMyPlaylists(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/playlists"))
                    XCTAssertTrue(url.contains("page=2"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["playlists"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testBatchFetchPodcasts() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let ids = "2,2342,232,2442,232"
            parameters["ids"] = ids
            client.batchFetchPodcasts(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "POST")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                if let data = response.request?.httpBody {
                    if let postData = String(data: data, encoding: .utf8) {
                        XCTAssertEqual(postData, "ids=\(ids)")
                    } else {
                        XCTFail("Shouldn't be here")
                    }
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["podcasts"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testBatchFetchEpisodes() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let ids = "2,2342,232,2442,232"
            parameters["ids"] = ids
            client.batchFetchEpisodes(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "POST")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/episodes"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                if let data = response.request?.httpBody {
                    if let postData = String(data: data, encoding: .utf8) {
                        XCTAssertEqual(postData, "ids=\(ids)")
                    } else {
                        XCTFail("Shouldn't be here")
                    }
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["episodes"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testDeletePodcast() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            let reason = "asdfasfs"
            parameters["reason"] = reason
            client.deletePodcast(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "DELETE")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts/\(id)"))
                    XCTAssertTrue(url.contains("reason=\(reason)"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["status"].stringValue.count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }
        
        func testSubmitPodcast() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let rss = "http://myrss.com/rss"
            parameters["rss"] = rss
            client.submitPodcast(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "POST")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts/submit"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                if let data = response.request?.httpBody {
                    if let postData = String(data: data, encoding: .utf8) {
                        XCTAssertEqual(postData, "rss=\(rss)")
                    } else {
                        XCTFail("Shouldn't be here")
                    }
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["status"].stringValue.count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testFetchAudienceForPodcast() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let id = "fake_id"
            parameters["id"] = id
            client.fetchAudienceForPodcast(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts/\(id)/audience"))
                    XCTAssertFalse(url.contains("id=\(id)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["by_regions"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }

        func testFetchPodcastsByDomain() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            let domain_name = "npr.org"
            parameters["domain_name"] = domain_name
            parameters["page"] = "4"
            client.fetchPodcastsByDomain(parameters: parameters) { response in
                // No error
                if let _ = response.error {
                    XCTFail("Shouldn't be here")
                }
                XCTAssertEqual(response.request?.httpMethod!, "GET")
                // Correct query strings
                if let url = response.request?.url?.absoluteString {
                    XCTAssertTrue(url.contains("/api/v2/podcasts/domains/\(domain_name)"))
                    XCTAssertFalse(url.contains("domain_name=\(domain_name)"))
                } else {
                    XCTFail("Shouldn't be here")
                }
                
                // Correct response
                if let json = response.toJson() {
                    XCTAssertTrue(json["podcasts"].count > 0)
                } else {
                    XCTFail("Shouldn't be here")
                }
            }
        }                
    }
