<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	// controller 단
		//검색 , 카테고리
	String searchWord = request.getParameter("searchWord");
	if(request.getParameter("searchWord") == null) {
		searchWord = "";
	}
	
	String category = request.getParameter("category");
	if(request.getParameter("category") == null) {
		category = "";
	}
	//페이징
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	int startRow = (currentPage - 1) * rowPerPage;
	
	// model 단
	//1)mysql 드라이버 로딩
	Class.forName("com.mysql.cj.jdbc.Driver");
		// 디버깅
		System.out.println("드라이버 로딩 성공");
	
	// 변수 받기
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	// 페이징 변수 받기
	PreparedStatement stmt2 = null;
	ResultSet rs2 = null;
	
	// 2) sql 준비
	String listSql = "SELECT f.film_id filmId, f.title title, c.name name, f.release_year releaseYear"
						+ " FROM film f"
						+ " INNER JOIN film_category fc ON f.film_id = fc.film_id"
						+ " INNER JOIN category c ON fc.category_id = c.category_id";
	String countSql = "SELECT count(*) cnt"
						+ " FROM film f"
						+ " INNER JOIN film_category fc ON f.film_id = fc.film_id"
						+ " INNER JOIN category c ON fc.category_id = c.category_id";
		
		// 디버깅
		System.out.println("listSql: " + listSql);
		System.out.println("countSql: " + countSql);
		
	// 3) connction(접속)하기
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
		// 디버깅
		System.out.println("DB연결성공: " + conn);
		
		// 검색 + 카테고리 조건
		if(searchWord.equals("") && category.equals("")) { // 아무것도 하지 않았을 때
			listSql += " ORDER BY f.film_id LIMIT ?, ?";
		    countSql += "";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setInt(1, startRow);
			stmt.setInt(2, rowPerPage);
		
		} else if(!searchWord.equals("") && category.equals("")) { // 검색만 했을 때
			listSql += " WHERE f.title LIKE ? ORDER BY f.film_id LIMIT ?, ?";
			countSql += " WHERE f.title LIKE ?";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setString(1, "%" + searchWord + "%");
			stmt.setInt(2, startRow);
			stmt.setInt(3, rowPerPage);
			stmt2.setString(1, "%" + searchWord + "%");
			
		} else if(!category.equals("") && searchWord.equals("")) { // 카테고리만 했을 때
			listSql += " WHERE c.name = ? ORDER BY f.film_id LIMIT ?, ?";
			countSql += " WHERE c.name = ?";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setString(1, category);
			stmt.setInt(2, startRow);
			stmt.setInt(3, rowPerPage);
			stmt2.setString(1, category);
			
		} else {						// 둘다 했을 때
			listSql += " WHERE f.title LIKE ? AND c.name = ? ORDER BY f.film_id LIMIT ?, ?";
			countSql += " WHERE f.title LIKE ? AND c.name = ?";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setString(1, "%" + searchWord + "%");
			stmt.setString(2, category);
			stmt.setInt(3, startRow);
			stmt.setInt(4, rowPerPage);
			stmt2.setString(1, "%" + searchWord + "%");
			stmt2.setString(2, category);
		}
		
		
	// 5) ResultSet 실행
	rs = stmt.executeQuery();
	rs2 = stmt2.executeQuery();
		// 디버깅
		System.out.println("ResultSet: " + rs);
		System.out.println("ResultSet: " + rs2);
		
	// 전체 페이지
	int totalCnt = 0;
	if(rs2.next()) {
		totalCnt = rs2.getInt("cnt");
	}
	int lastPage = totalCnt / rowPerPage;
	if(totalCnt % rowPerPage != 0) {
		lastPage++;
	}
	// 디버깅 전체 행 수 출력 확인
		System.out.println("전체 행의 수: " + rs2.getInt("cnt"));
	
	// 페이징 수 나타내기
	int pageCount = 5;
	int startPage = ((currentPage - 1) / pageCount) * pageCount +1;
	int endPage = startPage + pageCount - 1;
	if(endPage > lastPage) {
		endPage = lastPage;
	}
	
	// 배열 리스트 받기
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		while(rs.next()) {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("filmId", rs.getInt("filmId"));
			map.put("title", rs.getString("title"));
			map.put("name", rs.getString("name"));
			map.put("releaseYear", rs.getInt("releaseYear"));
			
			list.add(map);
			
			
		}
%>
<!-- view 단 -->

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
	<style>
		 .nolink {  /*링크 밑줄 제거 */
		 	text-decoration: none;
		 	color: black; /* 필요시 색상 지정 */
		 }
		 
		 	.nolink:hover {
		 		color: #007b; /* 마우스 오버 시 색상 변경 */
		 	}
		 	/*border말고 다른 테이블 코드*/
	 	table {
	 		width: 50%;
	 		border-collapse: separate; /* 중요: collapse명 둥글게 안 보임*/
	 		border-spacing: 50;		/* 셀 간격*/
	 		border-radius: 5px;		/* 둥근 모서리*/	
	 		overflow: hidden;        /* 꼭 필요: 둥근 모서리가 잘리지 않게*/
	 		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 그림자도 예쁘게*/
	 		border: 2px solid #ccc;
	 	}	
	 	th, td {
	 		padding: 12px 16px;
	 		text-align: left;
	 		background-color: #fff;
	 		border: 1px solid #bbb;
	 	}
	 	
	 	th {
	 		background-color: #f4F4F4;
	 		font-weight: bold;
	 		color: #000;
	 	}
	 	
	 	th:nth-child(even) {
	 		background-color: #f9f9f9;
	 	}
	 	
	 	th:hover {
	 		background-color: #eef6ff;
	 	}
	 	
	</style>
</head>
<body>
	<h1>영화 리스트</h1>
	<table>
		<tr>
			<th>NO</th>
			<th>영화제목</th>
			<th>카테고리</th>
			<th>출시연도</th>
		</tr>
	<%
		Set<String> seen = new HashSet<>(); // 카테고리 중복 제거용
		
		for(HashMap<String, Object> map : list) {
			
	%>
		<tr>
			<td><%=map.get("filmId") %></td>
			<td><a class="nolink" href="/sakila/d0326/filmOne.jsp?filmId=<%=map.get("filmId") %>"><%=map.get("title") %></th>
			<td><%=map.get("name") %></td>
			<td><%=map.get("releaseYear") %></td>
		</tr>
	<%
			}
	%>
	</table>
	<!--  select는 별도로, list 한번 더 돌려야 함 -->
	<form action="/sakila/d0326/filmList.jsp">
	<select name="category">
	<%
    // 카테고리 select 박스용 별도 쿼리
    String categorySql = "SELECT DISTINCT name FROM category";
    PreparedStatement categoryStmt = conn.prepareStatement(categorySql);
    ResultSet categoryRs = categoryStmt.executeQuery();
	%>
	<option value="">전체</option> <!-- 전체 항목 추가! -->
	<%
		while (categoryRs.next()) {
        	String name = categoryRs.getString("name");
	%>
		<option value="<%=name %>"<%=name.equals(category) ? "selected" : ""%>><%=name %></option>
	<%
		
		}
	%>
		<input type="text" name="searchWord" value="<%=searchWord %>">
	</select>
		<button type="submit">검색</button>
		<a href= "/sakila//d0326/filmList.jsp?">초기화</a>
	</form>
	<!--  페이징 -->
		<a href="/sakila//d0326/filmList.jsp?currentPage=1&category=<%=category %>&searchWord=<%=searchWord %>">[처음]</a>
	<%
		// 10개 이전 할 경우
		if(currentPage > 1) {
			int prevPage = currentPage - 10;
			if(prevPage < 1) prevPage = 1;
	%>
		<a href="/sakila//d0326/filmList.jsp?currentPage=<%=prevPage %>&category=<%=category %>&searchWord=<%=searchWord %>">[이전]</a>
	<%
		}
		for(int i = startPage; i<= endPage; i++) {
	%>
		<a href="/sakila//d0326/filmList.jsp?currentPage=<%=i %>&category=<%=category %>&searchWord=<%=searchWord %>">[<%=i %>]</a>
	<%
		}
	%>
	<%
		// 10 다음 할 경우
		if(currentPage < lastPage) {
			int nextPage = currentPage + 10;
			if(nextPage > lastPage) nextPage = lastPage;
	%>
		<a href="/sakila//d0326/filmList.jsp?currentPage=<%=nextPage %>&category=<%=category %>&searchWord=<%=searchWord %>">[다음]</a>
	<%
		}
	%>
		<a href="/sakila//d0326/filmList.jsp?currentPage=<%=lastPage %>&category=<%=category %>&searchWord=<%=searchWord %>">[마지막]</a>
</body>
</html>







