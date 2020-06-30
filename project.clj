(defproject onwebed-cli "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.2-alpha1"]
                 [org.clojure/clojurescript "1.9.854"]
                 [org.clojure/tools.cli "1.0.194"]
                 [prismatic/schema "1.1.12"]]
  :plugins [[lein-cljsbuild "1.1.8"] [lein-cljfmt "0.6.7"]]
  :main ^:skip-aot onwebed-cli.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}}
  :cljsbuild {:builds [{:id "dev"
                        :source-paths ["src"]
                        :compiler {:main onwebed-cli.core
                                   :output-to "package/index.js"
                                   :target :nodejs
                                   :output-dir "target_dev"
                                   :optimizations :none
                                   :pretty-print false
                                  ;;  :foreign-libs [{:file "resources/libs/helpers.js"
                                  ;;                  :provides ["helpers"]
                                  ;;                  :module-type :commonjs}]
                                  ;;  :npm-deps {:xml-js "1.6.11"}
                                   :parallel-build true}}

                       {:id "prod"
                        :source-paths ["src"]
                        :compiler {:main onwebed-cli.core
                                   :output-to "package/index.js"
                                   :target :nodejs
                                   :output-dir "target"
                                   :optimizations :advanced
                                   :pretty-print false
                                   :parallel-build true}}]})
